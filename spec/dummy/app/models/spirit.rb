class Spirit < ApplicationRecord
  include Fae::BaseModelConcern
  
  # has_fae_cta :some_other_cta
  # has_fae_cta :website_cta

  has_fae_image :logo
  has_fae_file :pdf_upload

  has_many :sub_spirits, dependent: :destroy

  validates :name, presence: true

  def fae_display_field
    name
  end

end
