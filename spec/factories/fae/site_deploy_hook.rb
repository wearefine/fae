FactoryBot.define do
  factory :fae_site_deploy_hook, class: 'Fae::SiteDeployHook' do
    sequence(:environment) { |n| "Env#{n}" }
    sequence(:url) { |n| "Url#{n}" }

    association :site, factory: :fae_site
  end
end