# Host apps can override this by calling MuxRuby.configure in their own initializer.
MuxRuby.configure do |config|
  config.username = ENV['MUX_TOKEN_ID']
  config.password = ENV['MUX_TOKEN_SECRET']
end
