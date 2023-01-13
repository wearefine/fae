FactoryBot.define do
  factory :fae_deploy, :class => 'Fae::Deploy' do
    association :user, factory: :fae_user
    user_name 'Deploy Person'
    external_deploy_id 'a53ea0d3-55b2-4e83-8e14-a0c56aaf8992'
  end
end