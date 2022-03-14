Rails.application.config.to_prepare do
  Judge.configure do
    expose Release, :name
    expose ValidationTester, :slug, :second_slug
  end
end