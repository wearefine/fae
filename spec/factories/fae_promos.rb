# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fae_promo, :class => 'Promo' do
    headline "MyString"
    body "MyText"
    link "MyString"
    link ""
  end
end
