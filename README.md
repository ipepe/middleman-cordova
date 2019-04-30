# middleman-cordova
WARNING! This is work in progress! Use at Your own responsibility!
Middleman integrated with Cordova to build hybrid apps.

# Why
Building apps with cordova is often frustrating, because many times something will break and You have to create whole cordova project from scratch. This extension for Middleman treats cordova as build tool, and whole cordova directory as artifacts. Rebuilding whole cordova project is a simple task that will be done for You by this extesion.

# Middleman config.rb
```ruby
activate :cordova do |cordova|
  cordova.package_id = 'com.cogibyte.devapp'
  cordova.version = [1, Time.now.strftime('%y%m'), Time.now.strftime('%d%H%M')].join('.')
  cordova.author = { email: 'apps@cogibyte.com', href: 'cogibyte.com', name: 'CogiByte' }
  cordova.platforms = [:android, :ios]
  cordova.hooks = ['prepareIconsAndSplashScreens.sh']
  cordova.plugins = []
  cordova.build_dir_expires_in_minutes = 60*4
end
```

# Middleman commands
`middleman run ios`

`middleman run android`

`middleman openide ios`

`middleman openide android`