FactoryBot.define do

  factory :fae_user, class: 'Fae::User' do
    sequence(:first_name) { |n| "Andy#{n}" }
    sequence(:last_name) { |n| "Doe#{n}" }
    email
    sequence(:password) { |n| "Passw0rd#{n}" }
    password_confirmation { password }
    active true

    association :role, factory: :fae_role

    trait :with_otp do
      otp_required_for_login { true }

      after(:build) do |user, _evaluator|
        user.otp_secret = Fae::User.generate_otp_secret
        user.generate_otp_backup_codes!
      end
    end
  end

end