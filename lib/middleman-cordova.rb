require "middleman-core"

Middleman::Extensions.register :middleman-cordova do
  require "my-extension/extension"
  MyExtension
end
