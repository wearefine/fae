FactoryGirl.define do

  factory :release do
    sequence(:name) { |n| "Release Name #{n}" }
    sequence(:slug) { |n| "release-name-#{n}" }
    release_date { 10.days.ago }

    wine
  end

end