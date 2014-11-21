FactoryGirl.define do

  factory :varietal do
    sequence(:name) { |n| "Varietal Name #{n}" }
  end

end