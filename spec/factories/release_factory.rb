FactoryGirl.define do

  factory :release do
    sequence(:name) { |n| "Release Name #{n}" }

    wine
  end

end