FactoryGirl.define do

  factory :release_note do
    sequence(:title) { |n| "Release Note #{n}" }

    release
  end

end