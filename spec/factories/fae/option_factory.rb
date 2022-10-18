FactoryBot.define do

  factory :fae_option, class: 'Fae::Option' do
    title 'My FINE Admin'
    singleton_guard 0
    time_zone 'Pacific Time (US & Canada)'
    live_url 'http://google.com'
  end

end