module Livable
  extend ActiveSupport::Concern

  included do
    # This file is installed (along with the settingslogic gem/setup) because the flex_componentable_concern.rb 
    # defines the polymorphic relationship with an active_flex_components variant that assumes the model has an active scope
    # that is driven from global app settings.
    # For example:
    # scope :active, -> { where(Settings.env_flag => true) }
    scope :active, -> {}
  end

end