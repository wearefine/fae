FactoryBot.define do

  factory :cat do
    sequence(:name) { |n| "Cat Name #{n}" }
  end

end