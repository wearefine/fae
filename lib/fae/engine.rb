module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae

    # include libraries
    require 'devise'
    require 'simple_form'
    require 'jquery-rails'
    require 'jquery-ui-rails'
    require 'remotipart'
    require 'judge'
    require 'judge/simple_form'
    require 'acts_as_list'
    require 'slim'

    config.autoload_paths += %W(#{config.root}/lib)

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
end
