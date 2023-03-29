FactoryBot.define do

  factory :sub_aroma do
    sequence(:name) { |n| "Sub Aroma Name #{n}" }

    aroma
  end

end