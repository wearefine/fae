FactoryGirl.define do

  factory :fae_text_field, class: 'Fae::TextField' do
    sequence(:label) { |n| "Text Field #{n}" }
  end

end