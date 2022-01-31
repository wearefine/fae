require 'devise'
require 'judge'
require_relative 'validation_helper_collection'

module Fae
  # configurable defaults
  class << self
    mattr_accessor :devise_secret_key, :devise_mailer_sender, :dashboard_exclusions, :max_image_upload_size, :max_file_upload_size, :languages, :recreate_versions, :validation_helpers, :track_changes, :tracker_history_length, :slug_separator, :disabled_environments, :per_page, :use_cache, :use_form_manager, :netlify

    self.devise_secret_key      = ''
    self.devise_mailer_sender   = 'change-me@example.com'
    self.dashboard_exclusions   = []
    self.max_image_upload_size  = 2
    self.max_file_upload_size   = 5
    self.languages              = {}
    self.recreate_versions      = false
    self.validation_helpers     = ValidationHelperCollection.new
    self.track_changes          = true
    self.tracker_history_length = 15
    self.slug_separator         = '-'
    self.disabled_environments  = []
    self.per_page               = 25
    self.use_cache              = false
    self.use_form_manager       = false
    self.netlify                = {}
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self

    # assign initializer configs
    Devise.secret_key = Fae.devise_secret_key
    Devise.mailer_sender = Fae.devise_mailer_sender
    Kaminari.config.default_per_page = Fae.per_page
  end
end
