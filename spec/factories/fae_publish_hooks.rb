# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fae_publish_hook, :class => 'PublishHook' do
    url "MyString"
    environment "MyString"
    last_published_at "2021-09-28 12:10:57"
  end
end
