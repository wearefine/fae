class PrivacyPage < ApplicationRecord
  include Fae::BaseModelConcern

  has_fae_image :social_media_image

  validates :title, presence: true

  def fae_display_field
    title
  end
end
