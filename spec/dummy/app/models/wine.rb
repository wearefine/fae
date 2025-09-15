class Wine < ActiveRecord::Base
  include Fae::BaseModelConcern
  include FlexComponentableConcern

  acts_as_list add_new_at: :top

  has_many :releases
  has_many :winemakers

  has_fae_cta :test_cta_en
  has_fae_cta :test_cta_zh
  has_fae_cta :test_cta_ja

  has_many :oregon_winemakers, -> { where(region_type: 1) },
    class_name: 'Winemaker'

  has_many :california_winemakers, -> { where(region_type: 2) },
    class_name: 'Winemaker'

  validates :name_en, presence: true

  fae_translate :name
  fae_image_translate :image
  fae_file_translate :pdf

  has_fae_image :image_en
  has_fae_image :image_frca

  has_fae_file :pdf_en
  has_fae_file :pdf_frca

  def fae_display_field
    name_en
  end

  def self.for_fae_index
    order(:position)
  end

end
