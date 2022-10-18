FactoryBot.define do

  factory :fae_static_page, class: 'Fae::StaticPage' do
    sequence(:title) { |n| "Page Title #{n}" }
  end

end