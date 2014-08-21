require 'devise'

module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae

    # include libraries
    require 'simple_form'

    # set config defaults
    config
  end

  # configuraable defaults
  class << self
    mattr_accessor :title, :logo_path
    self.title      = "My FINE Admin"
    self.logo_path  = "/assets/fae/logo.png"
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end
end
