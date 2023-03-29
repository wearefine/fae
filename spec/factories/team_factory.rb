FactoryBot.define do

  factory :team do
    sequence(:name) { |n| "Team Name #{n}" }
  end

end