Fae.setup do |config|

  ## deploy_notifications_mailer_sender
  # This email address will get passed to Fae and
  # used as the from address in the deploy notification emails.
  # config.deploy_notifications_mailer_sender = 'change-me@example.com'

  ## devise_mailer_sender
  # This email address will get passed to Devise and
  # used as the from address in the password reset emails.
  # config.devise_mailer_sender = 'change-me@example.com'

  ## dashboard_exclusions
  # The dashboard will show all objects with recent activity.
  # To exclude any objects, add them to this array.
  # config.dashboard_exclusions = %w( Gallery )

  ## max_image_upload_size
  # This will set a file size limit on image uploads in MBs.
  # The default is 2 MB.
  # config.max_image_upload_size = 2

  ## max_file_upload_size
  # This will set a file size limit on file uploads in MBs.
  # The default is 5 MB.
  # config.max_file_upload_size = 5

  ## languages
  # This hash sets the supported languages for the multiple
  # language toggle feature.
  # config.languages = {
  #   en: 'English',
  #   zh: 'Chinese'
  # }

  ## recreate_versions
  # Triggers `Fae::Image` to recreate Carrierwave versions after save.
  # Defaults to false
  # config.recreate_versions = false

  ## track_changes
  # This is the global toggle for the change tracker.
  # Defaults to true
  # config.track_changes = true

  ## tracker_history_length
  # This defines how many changes per object are kept in the DB
  # via the change tracker.
  # Defaults to 15
  # config.tracker_history_length = 15

  ## disabled_environments
  # This option will disable Fae complete when the app is running
  # on one of the defined environments
  # config.disabled_environments = [ :preview, :staging ]

  ## per_page
  # Sets the default number of items shown in paginated lists
  # Defaults to 25
  # config.per_page = 25

  ## use_cache
  # Determines whether or not Fae will utilize cache internally.
  # Note: you still need to enable `perform_caching` and set a `cache_store`
  # on the parent app
  # Defaults to false
  # config.use_cache = true

  ## use_form_manager
  # Enable Manage Form buttons in form headers
  # Defaults to false
  # config.use_form_manager = true

  ## Netlify configs
  # Environment variables are recommended for any sensitive Netlify configuration details.
  # config.netlify = {
  #   api_user: 'netlify-api-user',
  #   api_token: 'netlify-api-token',
  #   site: 'site-name-in-netlify',
  #   site_id: 'site-id-in-netlify',
  #   api_base: 'https://api.netlify.com/api/v1/',
  #   notification_hook_signature: 'netlify-notification-hook-signature'
  # }
end