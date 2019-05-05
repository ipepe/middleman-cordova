# Require core library
require 'middleman-core'

# Extension namespace
class MiddlemanCordovaExtension < ::Middleman::Extension
  class << self
    attr_accessor :options
  end
  option :package_id, 'org.example.app', 'Application package identifier (org.example.app)'
  option :application_name, 'Example App', 'Application name'
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
  option :build_before, true, 'Should integration build website before deploying to Mobile device'

  def after_configuration
    ::MiddlemanCordovaExtension.options = options
  end
end
