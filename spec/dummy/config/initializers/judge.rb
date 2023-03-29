Rails.application.config.to_prepare do
  Judge.configure do |config|
    expose Release, :name
    expose ValidationTester, :slug, :second_slug

    config.use_association_name_for_validations true
  end
end