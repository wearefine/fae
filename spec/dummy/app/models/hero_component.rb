class HeroComponent < ApplicationRecord
  include Fae::BaseModelConcern
  include Fae::BaseFlexComponentConcern
  has_flex_component name
  
  has_fae_image :image

  def fae_display_field
    title
  end

end
