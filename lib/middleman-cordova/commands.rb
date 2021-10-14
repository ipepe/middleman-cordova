# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'

module Middleman
  module Cli
    # This class provides a "cordova" command for the middleman CLI.
    class Cordova < Thor::Group
      include Thor::Actions

      check_unknown_options!

      argument :task, type: :string, default: 'help'
      argument :platform, type: :string, default: 'none'

      class_option :environment,
                   aliases: '-e',
                   default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'production',
                   desc: 'The environment Middleman will run under'

      class_option :verbose,
                   type: :boolean,
                   default: false,
                   desc: 'Print debug messages'

      class_option :instrument,
                   type: :boolean,
                   default: false,
                   desc: 'Print instrument messages'

      class_option :build_before,
                   type: :boolean,
                   aliases: '-b',
                   desc: 'Run `middleman build` before the cordova step'

      class_option :recreate,
                   type: :boolean,
                   desc: 'Switch to destroy whole cordova build directory and rebuild it from scratch'

      class_option :release,
                   type: :boolean,
                   desc: 'Switch to build production ready and signed build'

      def self.subcommand_help(_options)
        # TODO
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def cordova
        env = (options['environment'] || 'production').to_s.to_sym
        verbose = options['verbose'] ? 0 : 1
        instrument = options['instrument']

        @app = ::Middleman::Application.new do
          config[:mode] = :build
          config[:environment] = env
          ::Middleman::Logger.singleton(verbose, instrument)
        end

        # create variables before changing any directories
        prepopulate_path_variables

        case task
        when 'help'
          print_help
        when 'build'
          inside(ensure_cordova_build_directory) do
            integrate_middleman_with_cordova
            if platform == 'android'
              run("cordova build android#{release(:android)}")
            elsif platform == 'ios'
              run("cordova build ios#{release(:ios)}")
            else
              print_help
            end
            move_up_build_artifacts(platform)
          end
        when 'run'
          inside(ensure_cordova_build_directory) do
            integrate_middleman_with_cordova
            if platform == 'android'
              run("cordova run android#{release(:android)}")
            elsif platform == 'ios'
              run("cordova run ios#{release(:ios)}")
            else
              print_help
            end
            move_up_build_artifacts(platform)
          end
        when 'openide'
          inside(ensure_cordova_build_directory) do
            if platform == 'android'
              raise NotImplementedError
            elsif platform == 'ios'
              if RUBY_PLATFORM.include?('darwin') # Mac OS X
                run("open -a \"Xcode\" #{cordova_build_dir_path}/platforms/ios/#{cordova_options[:application_name]}.xcworkspace/")
              else
                raise NotImplementedError
              end
            else
              print_help
            end
          end
        else
          print_help
        end
      end

      protected

      def prepopulate_path_variables
        pwd
        cordova_build_dir_path
      end

      def release(platform)
        if options['release']
          if cordova_options.platform_release_arguments[platform].present?
            ' --release -- ' + cordova_options.platform_release_arguments[platform]
          else
            ' --release'
          end
        end
      end

      def move_up_build_artifacts(platform)
        if options['release']
          FileUtils.mkdir_p(dist)
          if platform == 'android'
            FileUtils.rm_rf(File.join(dist, '*.apk'))
            `cp ./platforms/android/app/build/outputs/apk/release/*.apk #{dist}`
          end
        end
      end

      def ensure_cordova_build_directory
        if options['recreate'] || !cordova_build_directory_exists?
          FileUtils.rm_rf(cordova_build_dir_path)
          create_cordova_build
        end
        cordova_build_dir_path
      end

      def cordova_build_directory_exists?
        File.directory?(cordova_build_dir_path) && config_xml_exists?
      end

      def cordova_build_dir_path
        @cordova_build_dir_path ||= File.join(pwd, cordova_options.cordova_build_dir)
      end

      def pwd
        @pwd ||= Dir.pwd
      end

      def dist
        File.join(pwd, cordova_options.build_artifacts_path)
      end

      def config_xml_exists?
        File.file?(cordova_build_dir_path + '/config.xml')
      end

      def build_dir_expired?
        true # TODO: fix when false
      end

      def create_cordova_build
        FileUtils.mkdir_p(cordova_build_dir_path)
        run([
          'cordova create',
          cordova_build_dir_path,
          cordova_options[:package_id],
          cordova_options[:application_name]
        ].join(' '))
        # TODO: link build into www inside cordova dir
        inside(cordova_build_dir_path) do
          cordova_options.platforms.each do |platform|
            platform_version = cordova_options.platform_versions.try(:[], platform) || 'latest'
            run("cordova platform add #{platform}@#{platform_version}")
          end
          cordova_options.plugins.each do |plugin_name|
            run("cordova plugin add #{plugin_name}")
          end
        end
      end

      def print_help
        run('cordova -v')
        raise NotImplementedError
      end

      def integrate_middleman_with_cordova
        inside(pwd) do
          build_before(options)
        end
        amend_cordova_config_xml
        copy_res_and_hooks
      end

      def amend_cordova_config_xml
        return unless File.exist?(cordova_build_dir_path + '/config.xml')

        original_xml = File.read(cordova_build_dir_path + '/config.xml')
        xml_handle = Nokogiri::XML(original_xml)
        xml_handle.css('widget').attr('version', cordova_options.version)
        xml_handle.css('description')[0].content = cordova_options.application_name

        xml_handle.css('author')[0].content = cordova_options.author[:name]
        xml_handle.css('author')[0].attribute('email').value = cordova_options.author[:email]
        xml_handle.css('author')[0].attribute('href').value = cordova_options.author[:href]

        cordova_options.config_xml_inside_platform.each do |platform, xml|
          xml_handle.at_css("platform[name='#{platform}']").add_child("\n" + xml)
        end

        xml_handle.css('platform').last.add_next_sibling("\n" + xml_after_platforms)

        File.write(cordova_build_dir_path + '/config.xml', xml_handle.to_xml)
        puts 'Updated config.xml with middleman cordova config'
      end

      def xml_after_platforms
        cordova_options.config_xml_after_platforms
      end

      def copy_res_and_hooks
        if File.directory?(pwd + '/res')
          FileUtils.mkdir_p(cordova_build_dir_path + '/res')
          FileUtils.cp_r(pwd + '/res', cordova_build_dir_path)
          puts 'Copied res folder into cordova build dir'
        end
      end

      def build_before(options = {})
        build_enabled = options.fetch('build_before', cordova_options.build_before)

        if build_enabled
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          run("middleman build -e #{options['environment']}") || exit(1)
        end
      end

      def print_usage_and_die(message)
        raise StandardError, "ERROR: #{message}"
      end

      def cordova_options
        options = nil

        begin
          options = ::MiddlemanCordovaExtension.options
        rescue NoMethodError
          print_usage_and_die 'You need to activate the cordova extension in config.rb.'
        end

        options
      end
    end

    # Add to CLI
    Base.register(Middleman::Cli::Cordova, 'cordova', 'cordova [task] [platform*]', 'Cordova integration')

    # Alias "d" to "cordova"
    Base.map('c' => 'cordova')
  end
end
