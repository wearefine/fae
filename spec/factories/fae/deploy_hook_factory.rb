FactoryGirl.define do
  factory :fae_deploy_hook, :class => 'Fae::DeployHook' do
    url "https://api.netlify.com/build_hooks/1234"
    environment "Production"
  end
end