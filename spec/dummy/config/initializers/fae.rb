Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  config.devise_mailer_sender = 'test@test.com'

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Aroma )

  # language support
  config.languages = {
    en: 'English',
    zh: 'Chinese',
    ja: 'Japanese'
  }

  # has_top_nav has been deprecated, but keeping in to ensure definition doesn't rasie exceptions
  config.has_top_nav = true

  config.per_page = 5

end
