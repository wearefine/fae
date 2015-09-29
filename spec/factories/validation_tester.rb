FactoryGirl.define do

  factory :validation_tester do
    sequence(:name) { |n| "Validation Tester Name #{n}" }
  end

end