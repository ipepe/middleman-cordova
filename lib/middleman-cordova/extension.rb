# Require core library
require 'middleman-core'

# Extension namespace
class MiddlemanCordovaExtension < ::Middleman::Extension
  option :package_id, 'org.example.app', 'Application package identifier (org.example.app)'
  option :version, '0.1.0', 'Application version'
  option :author, {
    href: 'http://cordova.io',
    email: 'dev@cordova.apache.org',
    name: 'Apache Cordova Team'
  }, 'Application author (hash that contains: name, href, email)'
  option :platforms, [], 'Application platforms to compile'
  option :hooks, [], 'Cordova file hook names to run when building'
  option :plugins, [], 'Cordova plugins to include when building Application'
  option :build_dir_expires_in_minutes, 60, 'After what time, the cordova build directory should be rebuild'

  def initialize(app, options_hash = {}, &block)
    # Call super to build options from the options_hash
    super

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
    # puts options.my_option
  end

  def after_configuration
    # Do something
  end

  # A Sitemap Manipulator
  # def manipulate_resource_list(resources)
  # end

  # helpers do
  #   def a_helper
  #   end
  # end
end
