FactoryGirl.define do

  factory :acclaim do
    sequence(:publication) { |n| "Publication Name #{n}" }
  end

end