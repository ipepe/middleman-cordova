# middleman-cordova
WARNING! This is work in progress! Use at Your own responsibility!
Middleman integrated with Cordova to build hybrid apps.

# Why
Building apps with cordova is often frustrating, because many times something will break and You have to create whole cordova project from scratch. This extension for Middleman treats cordova as build tool, and whole cordova directory as artifacts. Rebuilding whole cordova project is a simple task that will be done for You by this extesion.

# Middleman config.rb
```ruby
activate :cordova do |cordova|
  cordova.package_id = 'com.cogibyte.devapp'
  cordova.application_name = 'DevApp'
  cordova.version = [1, Time.now.strftime('%y%m'), Time.now.strftime('%d%H%M')].join('.')
  cordova.author = { email: 'apps@cogibyte.com', href: 'cogibyte.com', name: 'CogiByte' }
  cordova.platforms = [:android, :ios]
  cordova.plugins = ['device', 'splashscreen']
  cordova.cordova_build_dir = 'cordova'
  cordova.config_xml_inside_platform[:android] = <<-XML
    <icon src="res/icon.png"/>
  XML
  cordova.config_xml_after_platforms = <<-XML
    <preference name="orientation" value="portrait"/>
    <preference name="ShowSplashScreenSpinner" value="false"/>
    <hook src="res/prepareIconsAndSplashScreens.sh" type="after_prepare"/>
  XML
end
```

# Middleman commands
`middleman run [ios|android]`
`middleman build [ios|android]`
`middleman openide [ios|android]`