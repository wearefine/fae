FactoryGirl.define do

  factory :location do
    sequence(:name) { |n| "Location Name #{n}" }
  end

end