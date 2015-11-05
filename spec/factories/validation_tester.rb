FactoryGirl.define do

  factory :validation_tester do
    sequence(:name) { |n| "Validation Tester Name #{n}" }
    second_slug 'valid-slug'
  end

end