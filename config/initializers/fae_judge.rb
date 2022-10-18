Rails.application.config.to_prepare do
  Judge.configure do
    expose Fae::User, :email
  end
end
