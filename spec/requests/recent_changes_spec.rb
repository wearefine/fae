require 'rails_helper'

describe 'recent_changes partial' do

  before(:each) do
    def new_admin_release_path
      Rails.application.routes.url_helpers.new_admin_release_path
    end

    def edit_admin_release_path(release)
      Rails.application.routes.url_helpers.edit_admin_release_path(release)
    end
  end

  it 'should not display on new forms' do
    admin_login
    get new_admin_release_path

    expect(response.body).to_not include('Recent Changes')
  end

  it 'should display on edit forms' do
    release = FactoryBot.create(:release)

    admin_login
    get edit_admin_release_path(release)

    expect(response.body).to include('Recent Changes')
  end

end

describe 'recent changes Inertia form component' do
  before do
    admin_login
  end

  it 'serializes tracked changes for an edit form' do
    beer = FactoryBot.create(:beer)
    beer.tracked_changes.create!(
      user: Fae::User.first,
      change_type: 'updated',
      updated_attributes: ['name']
    )

    get Rails.application.routes.url_helpers.edit_admin_beer_path(beer),
      headers: { 'X-Inertia' => 'true' }

    page = response.parsed_body

    expect(page['component']).to eq('Admin/Beers/Form')
    expect(page.dig('props', 'recentChanges', 'title')).to eq('Recent Changes')
    expect(page.dig('props', 'recentChanges', 'rows')).to include(
      a_hash_including('type' => 'updated', 'attrs' => 'name')
    )
  end

  it 'omits recent changes from a draft form' do
    beer = FactoryBot.create(:beer)

    get Rails.application.routes.url_helpers.edit_admin_beer_path(beer, draft: true),
      headers: { 'X-Inertia' => 'true' }

    expect(response.parsed_body.dig('props', 'recentChanges')).to be_nil
  end
end
