require "middleman-core"

Middleman::Extensions.register :cordova do
  require "middleman-cordova/extension"
  require "middleman-cordova/commands"
  MiddlemanCordovaExtension
end
