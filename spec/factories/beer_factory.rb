FactoryGirl.define do

  factory :beer do
    sequence(:name) { |n| "Beer #{n}" }
  end

end