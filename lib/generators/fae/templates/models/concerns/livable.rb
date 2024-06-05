module Livable
  extend ActiveSupport::Concern

  included do
    # This file is installed because the flex_componentable_concern.rb defines the polymorphic 
    # relationship with an active_flex_components variant that assumes the model has an active scope.
    # In our case, this is driven from the settingslogic gem.
    # For example:
    # scope :active, -> { where(Settings.env_flag => true) }

    # You can define your own active scope here, or remove the scoped association from the 
    # flex_componentable_concern.rb file.
    scope :active, -> {}
  end

end