FactoryGirl.define do

  factory :release do
    sequence(:name) { |n| "Release Name #{n}" }
    release_date Date.today

    wine
  end

end