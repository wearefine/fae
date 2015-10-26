FactoryGirl.define do

  factory :winemaker do
    sequence(:name) { |n| "Name #{n}" }
  end

end