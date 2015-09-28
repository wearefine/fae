class ValidationTester < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  validates :slug, Fae.validation_helpers.slug
  validates :slug,
    uniqueness: true,
    presence: true,
    format: {
      with: Fae.validation_helpers.slug_regex,
      multiline: true,
      message: 'no spaces or special characters'
    }
  validates :email,
    format: {
      with: Fae.validation_helpers.email_regex,
      message: 'must be valid email'
    }
  validates :url,
    format: {
      with: Fae.validation_helpers.url_regex,
      message: 'must be valid url'
    }
  validates :phone,
    format: {
      with: Fae.validation_helpers.phone_regex,
      multiline: true,
      message: 'must be valid phone number'
    }
  validates :zip,
    format: {
      with: Fae.validation_helpers.zip_regex,
      multiline: true,
      message: 'must be valid zip'
    }
  validates :canadian_zip,
    format: {
      with: Fae.validation_helpers.canada_and_us_zip_regex,
      multiline: true,
      message: 'must be valid zip'
    }
  validates :youtube_url,
    format: {
      with: Fae.validation_helpers.youtube_regex,
      message: 'must be valid youtube id'
    }

  def fae_display_field
    name
  end

end
