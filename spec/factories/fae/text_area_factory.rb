FactoryBot.define do

  factory :fae_text_area, class: 'Fae::TextArea' do
    sequence(:label) { |n| "Text Area #{n}" }
  end

end