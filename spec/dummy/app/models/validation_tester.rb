class ValidationTester < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  validates :slug,
    uniqueness: true,
    presence: true,
    format: {
      with: Fae.validation_helpers.slug_regex,
      multiline: true,
      message: 'no spaces or special characters'
    },
    allow_blank: true
  validates :email,
    format: {
      with: Fae.validation_helpers.email_regex,
      multiline: true,
      message: 'must be valid email'
    },
    allow_blank: true
  validates :url,
    format: {
      with: Fae.validation_helpers.url_regex,
      message: 'must be valid url'
    },
    allow_blank: true
  validates :zip,
    format: {
      with: Fae.validation_helpers.zip_regex,
      multiline: true,
      message: 'must be valid zip'
    },
    allow_blank: true
  validates :youtube_url,
    format: {
      with: Fae.validation_helpers.youtube_regex,
      message: 'must be valid youtube id'
    },
    allow_blank: true

  validates :second_slug, Fae.validation_helpers.slug
  validates :second_email, Fae.validation_helpers.email
  validates :second_url, Fae.validation_helpers.url
  validates :second_zip, Fae.validation_helpers.zip
  validates :second_youtube_url, Fae.validation_helpers.youtube_url

  def fae_display_field
    name
  end

end
