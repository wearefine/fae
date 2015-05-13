FactoryGirl.define do

  factory :wine do
    sequence(:name_en) { |n| "English Name #{n}" }
    sequence(:name_zh) { |n| "中国名字 #{n}" }
    sequence(:name_ja) { |n| "和名 #{n}" }
  end

end