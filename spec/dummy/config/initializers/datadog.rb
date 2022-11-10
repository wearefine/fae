Datadog.configure do |c|
  c.tracing.enabled = Rails.env.production?
  c.service = 'FAE Dummy'
  c.env = 'production'
end