FactoryGirl.define do

  factory :aroma do
    sequence(:name) { |n| "Aroma Name #{n}" }

    release
  end

end