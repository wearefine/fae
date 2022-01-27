FactoryGirl.define do
  factory :fae_publish_hook, :class => 'Fae::PublishHook' do
    url "https://api.netlify.com/build_hooks/1234"
    environment "Production"
  end
end