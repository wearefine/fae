class HeroComponent < ApplicationRecord
  include Fae::BaseModelConcern
  has_fae_image :image

  def fae_display_field
    title
  end

  include Fae::BaseFlexComponentConcern

  has_flex_component name

end
