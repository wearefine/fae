FactoryBot.define do

  factory :event do
    sequence(:name) { |n| "Event Name #{n}" }
    city 'Portland'
  end

end