FactoryGirl.define do

  factory :wine do
    sequence(:name) { |n| "Wine Name #{n}" }
  end

end