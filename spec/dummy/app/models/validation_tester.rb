class ValidationTester < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  validates :slug, Fae.validation_helpers.slug
  validates :second_slug,
    uniqueness: true,
    presence: true,
    format: {
      with: Fae.validation_helpers.slug_regex,
      message: 'no spaces or special characters'
    }
  validates :email,
    format: {
      with: Fae.validation_helpers.email_regex,
      message: 'must be valid email'
    }
  # validates :url, Fae.validation_helpers.url_regex
  # validates :phone, Fae.validation_helpers.phone_regex
  # validates :zip, Fae.validation_helpers.zip_regex
  # validates :canadian_zip, Fae.validation_helpers.canada_and_us_zip_regex
  # validates :youtube_url, Fae.validation_helpers.youtube_regex

  def fae_display_field
    name
  end

end
