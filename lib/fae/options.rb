require 'devise'
require 'judge'

module Fae
  # configurable defaults
  class << self
    mattr_accessor :devise_secret_key, :devise_mailer_sender, :dashboard_exclusions, :max_image_upload_size, :max_file_upload_size, :languages, :recreate_versions

    self.devise_secret_key      = ''
    self.devise_mailer_sender   = 'change-me@example.com'
    self.dashboard_exclusions   = []
    self.max_image_upload_size  = 2
    self.max_file_upload_size   = 5
    self.languages              = {}
    self.recreate_versions      = false

    def validation_helpers
      self.slug_regex              = /^[-a-zA-Z0-9]+$/
      self.email_regex             = /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
      self.url_regex               = URI::regexp(%w(http https))
      self.phone_regex             = /^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/
      # http://stackoverflow.com/questions/16699007/regular-expression-to-match-standard-10-digit-phone-number
      self.zip_regex               = /^(\d{5})?$/i
      self.canada_and_us_zip_regex = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXYabceghjklmnpstvxy]{1}\d{1}[A-Za-z]{1} ?\d{1}[A-Za-z]{1}\d{1})$/
      # http://geekswithblogs.net/MainaD/archive/2007/12/03/117321.aspx
      self.youtube_regex           = /[a-zA-Z0-9_-]{11}/

      require 'pry'
      binding.pry
      self.slug = {
        uniqueness: true,
        presence: true,
        format: {
          with: Options.self.slug_regex,
          message: "no spaces or special characters",
          multiline: true
        }
      }
    end
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end

end