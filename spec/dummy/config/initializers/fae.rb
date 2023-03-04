Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  config.devise_mailer_sender = 'test@test.com'

  config.max_image_upload_size = 1

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Aroma PolyThing )

  # language support
  config.languages = {
    en: 'English',
    zh: 'Chinese',
    ja: 'Japanese',
    cs: 'Czech'
  }

  config.per_page = 5

  config.use_form_manager = true

  if Rails.env.development? || Rails.env.test?
    config.netlify = {
      api_user: ENV['FINE_NETLIFY_API_USER'],
      api_token: ENV['FINE_NETLIFY_API_TOKEN'],
      site: 'fine-pss',
      site_id: 'bb32173b-9ff2-4d9d-860a-2683ae4e1e2b',
      api_base: 'https://api.netlify.com/api/v1/'
    }
  else
    config.netlify = {
      api_user: Rails.application.secrets.fine_netlify_api_user,
      api_token: Rails.application.secrets.fine_netlify_api_token,
      site: 'fine-pss',
      site_id: 'bb32173b-9ff2-4d9d-860a-2683ae4e1e2b',
      api_base: 'https://api.netlify.com/api/v1/'
    }
  end
end
