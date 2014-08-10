module Fae
  class Engine < Rails::Engine
    initializer 'fae.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Fae::FormHelper
      end
    end
  end
end