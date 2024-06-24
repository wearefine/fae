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

  # Removed for now to simplify render.com deploy
  if Rails.env.test? || Rails.env.development?
    config.netlify = {
      api_user: ENV['FINE_NETLIFY_API_USER'],
      api_token: ENV['FINE_NETLIFY_API_TOKEN'],
      site: 'nuxt3-pss-deployment-refactor',
      site_id: '6b73c3a4-dd29-4acf-b65a-c9745b0f08eb',
      api_base: 'https://api.netlify.com/api/v1/',
      notification_hook_signature: '123test'
    }
  end
end
