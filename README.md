# middleman-cordova
WARNING! This is work in progress! Use at Your own responsibility!
Middleman integrated with Cordova to build hybrid apps.

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