module Fae
  module Livable
    extend ActiveSupport::Concern
  
    included do
      scope :active, -> { where(Settings.env_flag => true) }
    end
  
  end
end