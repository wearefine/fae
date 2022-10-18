FactoryBot.define do

  factory :fae_user, class: 'Fae::User' do
    sequence(:first_name) { |n| "Andy#{n}" }
    sequence(:last_name) { |n| "Doe#{n}" }
    email
    sequence(:password) { |n| "Passw0rd#{n}" }
    password_confirmation { password }
    active true

    association :role, factory: :fae_role
  end

end