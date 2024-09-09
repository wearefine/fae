FactoryBot.define do
  factory :fae_site, class: 'Fae::Site' do
    sequence(:name) { |n| "Site #{n}" }
    netlify_site 'site'
    netlify_site_id 'abc123'
  end
end