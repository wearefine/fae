FactoryGirl.define do

  factory :fae_page, class: 'Fae::Page' do
    sequence(:title) { |n| "Page Title #{n}" }
  end

end