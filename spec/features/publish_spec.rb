require 'spec_helper'

feature 'Publish' do

  before(:each) do
    super_admin_login
  end

  scenario 'draws deploys table', js: true do
    visit fae.publish_path
    expect(page).to have_content('ready')
  end

  scenario 'loads changes tables', js: true do
    FactoryGirl.create(:beer, name: 'New Beer')
    old_beer = FactoryGirl.create(:beer, name: 'Old Beer')
    old_beer.tracked_changes.first.update_columns(updated_at: DateTime.new(2020, 10, 20))

    visit fae.publish_path

    within('#production_changes') do
      expect(page).to have_content('New Beer')
      expect(page).to_not have_content('Old Beer')
    end

    within('#staging_changes') do
      expect(page).to have_content('New Beer')
      expect(page).to_not have_content('Old Beer')
    end
  end

end
