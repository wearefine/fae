FactoryBot.define do
  sequence :email do |n|
    "test#{n}@test.com"
  end
end