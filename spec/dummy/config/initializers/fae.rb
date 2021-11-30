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

  config.netlify = {
    api_user: ENV['FINE_NETLIFY_API_USER'],
    api_token: ENV['FINE_NETLIFY_API_TOKEN'],
    site: 'nelson-global',
    site_id: 'd294f9f6-2434-4fa3-841e-40a1d948bf90',
    api_base: 'https://api.netlify.com/api/v1/',
    build_hooks: {
      production: 'https://api.netlify.com/build_hooks/614b5d93745aeefacb1a7fcb',
      staging: 'https://api.netlify.com/build_hooks/6172c78c9be3dd3e66aa5a34',
      development: ''
    }
  }

end
