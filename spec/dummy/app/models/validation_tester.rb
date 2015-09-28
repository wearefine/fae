class ValidationTester < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  # validates :slug, Fae::ValidationHelpers.slug
  validates :slug,
    uniqueness: true,
    presence: true,
    format: {
      with: Fae.validation_helpers.slug_regex,
      multiline: true,
      message: 'no spaces or special characters'
    }
  # validates :email,
  #   format: {
  #     with: Fae::ValidationHelpers.email_regex,
  #     message: 'must be valid email'
  #   }
  # validates :url,
  #   format: {
  #     with: Fae::ValidationHelpers.url_regex,
  #     message: 'must be valid url'
  #   }
  # validates :phone,
  #   format: {
  #     with: Fae::ValidationHelpers.phone_regex,
  #     multiline: true,
  #     message: 'must be valid phone number'
  #   }
  # validates :zip,
  #   format: {
  #     with: Fae::ValidationHelpers.zip_regex,
  #     multiline: true,
  #     message: 'must be valid zip'
  #   }
  # validates :canadian_zip,
  #   format: {
  #     with: Fae::ValidationHelpers.canada_and_us_zip_regex,
  #     multiline: true,
  #     message: 'must be valid zip'
  #   }
  # validates :youtube_url,
  #   format: {
  #     with: Fae::ValidationHelpers.youtube_regex,
  #     message: 'must be valid youtube id'
  #   }

  def fae_display_field
    name
  end

end
