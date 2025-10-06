class HeroComponent < ApplicationRecord
  include Fae::BaseModelConcern
  include Fae::BaseFlexComponentConcern
  has_flex_component name
  
  has_fae_image :image

  def fae_display_field
    title
  end

  def preview_image_url
    image.asset.present? && image.asset.url.present? ? image.asset.thumb.url : nil
  end

end
