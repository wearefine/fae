FactoryGirl.define do

  factory :fae_publish_hook, class: 'Fae::PublishHook' do
    name "Production"
    url "https://api.netlify.com/build_hooks/1234"
    admin_environment "production"
  end

end