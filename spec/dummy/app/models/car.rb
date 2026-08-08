class Car < ApplicationRecord
  include Fae::BaseModelConcern
  has_fae_image :image_zh

  has_fae_image :image_frca

  has_fae_image :image_en

  def fae_display_field
    name_en
  end

  def self.for_fae_index
    order(:name_en)
  end

end
