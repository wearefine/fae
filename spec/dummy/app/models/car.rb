class Car < ApplicationRecord
  include Fae::BaseModelConcern

  belongs_to :car_category

  has_fae_image :image_zh

  has_fae_image :image_frca

  has_fae_image :image_en

  validates :name_en, presence: true
  validates :car_category, presence: true

  def fae_display_field
    name_en
  end

  def self.for_fae_index
    where(draft: false).order(:name_en)
  end

end
