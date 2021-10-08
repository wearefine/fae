Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  config.devise_mailer_sender = 'test@test.com'

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Aroma )

  # language support
  config.languages = {
    en: 'English',
    zh: 'Chinese',
    ja: 'Japanese',
    cs: 'Czech'
  }

  config.per_page = 5

  config.use_form_manager = true

  config.netlify_api_user   = ENV['FINE_NETLIFY_API_USER']
  config.netlify_api_token  = ENV['FINE_NETLIFY_API_TOKEN']
  config.netlify_site       = 'nelson-global'
  config.netlify_site_id    = 'd294f9f6-2434-4fa3-841e-40a1d948bf90'
  config.netlify_api_base   = 'https://api.netlify.com/api/v1/'

end
