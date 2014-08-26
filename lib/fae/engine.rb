require 'devise'

module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae

    # include libraries
    require 'simple_form'
    require 'jquery-ui-rails'

    config.to_prepare do
      ApplicationController.helper(FormHelper)
    end
  end

  # configurable defaults
  class << self
    mattr_accessor :title, :logo_path, :live_url, :stage_url, :support_url, :nav_items, :devise_secret_key, :devise_mailer_sender

    self.title        = 'My FINE Admin'
    self.logo_path    = '/assets/fae/logo.png'
    self.live_url     = '#'
    self.stage_url    = '#'
    self.support_url  = nil
    self.nav_items    = []

    # the secret key can't be hard coded here, but must be generated in Fae install script
    self.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'
    self.devise_mailer_sender = 'change-me@example.com'
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end
end
