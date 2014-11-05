require 'devise'
require 'judge'

module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae

    # include libraries
    require 'simple_form'
    require 'jquery-ui-rails'
    require 'remotipart'
    require 'judge'
    require 'judge/simple_form'

    config.autoload_paths += %W(#{config.root}/lib)

    config.to_prepare do
      ApplicationController.helper(ApplicationHelper)
    end
  end

  # configurable defaults
  class << self
    mattr_accessor :nav_items, :devise_secret_key, :devise_mailer_sender
    self.nav_items = []

    # the secret key can't be hard coded here, but must be generated in Fae install script
    self.devise_secret_key = ''
    self.devise_mailer_sender = 'change-me@example.com'
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end
end
