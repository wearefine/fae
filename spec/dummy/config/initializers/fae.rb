Fae.setup do |config|

  config.devise_secret_key = '1a84e7c357a86200f4f51dfbbce2d9cc3ee2a955744c6b390c9ee5de90559895686bc2e5408bcf8433e5091830c9d2407c21e3a84540f58d4c896327d732a54c'

  config.devise_mailer_sender = 'test@test.com'

  config.max_image_upload_size = 1

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Aroma PolyThing )

  # language support
  config.languages = {
    en: 'English',
    zh: 'Chinese',
    frca: "French Canadian"
  }

  config.per_page = 5

  config.use_form_manager = true

  # Removed for now to simplify render.com deploy
  if Rails.env.test?
    config.netlify = {
      api_user: ENV['FINE_NETLIFY_API_USER'],
      api_token: ENV['FINE_NETLIFY_API_TOKEN'],
      site: 'fine-pss',
      site_id: 'a1b2c3d4',
      api_base: 'https://api.netlify.com/api/v1/'
    }
  end

  config.open_ai_api_key = ENV["OPEN_AI_API_KEY"]
end
