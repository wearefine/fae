FactoryBot.define do

  factory :release do
    sequence(:name) { |n| "Release Name #{n}" }
    release_date { 10.days.ago }

    wine
  end

end