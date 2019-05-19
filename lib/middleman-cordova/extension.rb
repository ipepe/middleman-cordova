# Require core library
require 'middleman-core'

# Extension namespace
class MiddlemanCordovaExtension < ::Middleman::Extension
  class << self
    attr_accessor :options
  end
  option :cordova_build_dir, 'cordova', 'Name of directory for cordova artifacts'
  option :package_id, 'org.example.app', 'Application package identifier (org.example.app)'
  option :application_name, 'Example App', 'Application name'
  option :version, '0.1.0', 'Application version'
  option :author, {
    href: 'http://cordova.io',
    email: 'dev@cordova.apache.org',
    name: 'Apache Cordova Team'
  }, 'Application author (hash that contains: name, href, email)'
  option :platforms, [], 'Application platforms to compile'
  option :plugins, [], 'Cordova plugins to include when building Application'
  option :build_before, true, 'Should integration build website before deploying to Mobile device'

  option :config_inside_platform, {}, 'XML snippet to inject into cordovas config.xml inside specific platform'
  option :config_inject_xml_after_platforms, '', 'XML snippet to inject into cordovas config.xml'

  expose_to_template :cordova
  def cordova
    options
  end

  def after_configuration
    ::MiddlemanCordovaExtension.options = options
  end
end
