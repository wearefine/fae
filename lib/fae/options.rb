require 'devise'
require 'judge'
require_relative 'validation_helper_collection'

module Fae
  # configurable defaults
  class << self
    mattr_accessor :devise_secret_key, :devise_mailer_sender, :dashboard_exclusions, :max_image_upload_size, :max_file_upload_size, :languages, :recreate_versions, :validation_helpers, :track_changes, :tracker_history_length, :slug_separator

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
  end

  # this function maps the vars from your app into your engine
  def self.setup(&block)
    yield self
  end
end