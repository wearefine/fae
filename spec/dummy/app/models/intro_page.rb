class IntroPage < ApplicationRecord
  include Fae::BaseModelConcern
  has_fae_file :pdf

  has_fae_image :image

  validates :date, presence: true

  def fae_display_field
    title
  end

  belongs_to :article
end
