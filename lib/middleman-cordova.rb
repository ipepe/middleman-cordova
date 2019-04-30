require "middleman-core"

Middleman::Extensions.register :cordova do
  require "middleman-cordova/extension"
  MiddlemanCordovaExtension
end
