FactoryGirl.define do

  factory :person do
    sequence(:name) { |n| "Person Name #{n}" }
  end

end