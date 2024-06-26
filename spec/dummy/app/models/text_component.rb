class TextComponent < ApplicationRecord
  include Fae::BaseModelConcern
  include Fae::BaseFlexComponentConcern
  has_flex_component name
  
  def fae_display_field
    name
  end


end
