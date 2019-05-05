require 'fileutils'

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


        case task
        when 'help'
          print_help
        when 'run'
          build_before(options)
          inside(ensure_cordova_build_directory) do
            if platform == 'android'
              run("cordova run android")
            elsif platform == 'ios'
              run("cordova run ios")
            else
              print_help
            end
          end
        when 'openide'
          inside(ensure_cordova_build_directory) do
            if platform == 'android'
              raise NotImplementedError
            elsif platform == 'ios'
              raise NotImplementedError
            else
              print_help
            end
          end
        else
          print_help
        end
      end

      protected

      def ensure_cordova_build_directory
        if config_xml_exists?
          if build_dir_expired?
            FileUtils.rm_rf(cordova_build_dir_path)
            create_cordova_build
          end
        else
          create_cordova_build
        end
        cordova_build_dir_path
      end

      def cordova_build_dir_path
        @cordova_build_dir_path ||= Dir.pwd + '/cordova_build'
      end

      def config_xml_exists?
        File.file?(cordova_build_dir_path + '/config.xml')
      end

      def build_dir_expired?
        true #TODO: fix when false
      end

      def create_cordova_build
        FileUtils.mkdir_p(cordova_build_dir_path)
        run([
              "cordova create",
              cordova_build_dir_path,
              cordova_options[:package_id],
              cordova_options[:application_name]
        ].join(' '))
        # TODO: link build into www inside cordova dir
        inside(cordova_build_dir_path) do
          cordova_options.platforms.each do |platform|
            run("cordova platform add #{platform}")
          end
        end
      end

      def print_help
        puts "Wrong command"
      end

      def build_before(options = {})
        build_enabled = options.fetch('build_before', cordova_options.build_before)

        if build_enabled
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          run("middleman build -e #{options['environment']}") || exit(1)
        end
      end

      def print_usage_and_die(message)
        fail StandardError, "ERROR: #{message}"
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