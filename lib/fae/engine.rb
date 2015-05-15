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
    require 'acts_as_list'

    config.autoload_paths += %W(#{config.root}/lib concerns)

    config.to_prepare do
      ApplicationController.helper(ApplicationHelper)
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end

  # configurable defaults
  class << self
    mattr_accessor :devise_secret_key, :devise_mailer_sender, :dashboard_exclusions, :max_image_upload_size, :max_file_upload_size, :languages

    self.devise_secret_key      = ''
    self.devise_mailer_sender   = 'change-me@example.com'
    self.dashboard_exclusions   = []
    self.max_image_upload_size  = 2
    self.max_file_upload_size   = 5
    self.languages              = {}
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end
end
