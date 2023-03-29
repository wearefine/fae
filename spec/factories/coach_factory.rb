FactoryBot.define do

  factory :coach do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }

    team
  end

end