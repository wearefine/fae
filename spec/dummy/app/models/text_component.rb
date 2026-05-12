class TextComponent < ApplicationRecord
  include Fae::BaseModelConcern
  include Fae::BaseFlexComponentConcern
  
  validates :name, presence: true

  def fae_display_field
    name
  end


end
