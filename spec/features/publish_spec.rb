require 'spec_helper'

feature 'Publish' do

  before(:each) do
    admin_login
    FactoryGirl.create(:fae_publish_hook, environment: 'Production')
    FactoryGirl.create(:fae_publish_hook, environment: 'Staging')
    FactoryGirl.create(:fae_publish_hook, environment: 'Development')
  end

  # test drawing both tables

  scenario 'draws buttons', js: true do
    visit fae.publish_path
    expect(page).to have_button('Publish Production', disabled: true)
    expect(page).to have_button('Publish Staging', disabled: true)
    expect(page).to have_button('Publish Development', disabled: true)
  end

  scenario 'draws deploying table', js: true do
    visit fae.publish_path
    expect(page).to have_content('DEPLOYING')
    expect(page).to have_content('Staging building')
    expect(page).to have_content('10/22/2021 2:57 pm')
    expect(page).to have_content('00:01:33')
  end

  scenario 'draws past deploys table', js: true do
    visit fae.publish_path
    expect(page).to have_content('PAST DEPLOYS')
    expect(page).to have_content('FINE dev update')
    expect(page).to have_content('FINE admin triggered a Staging build')
    expect(page).to have_content('Error!')
  end

  # Feature TBD
  # scenario 'loads changes tables', js: true do
  #   FactoryGirl.create(:beer, name: 'New Beer')
  #   old_beer = FactoryGirl.create(:beer, name: 'Old Beer')
  #   old_beer.tracked_changes.first.update_columns(updated_at: DateTime.new(2020, 10, 20))

  #   visit fae.publish_path

  #   within('#production_changes') do
  #     expect(page).to have_content('New Beer')
  #     expect(page).to_not have_content('Old Beer')
  #   end

  #   within('#staging_changes') do
  #     expect(page).to have_content('New Beer')
  #     expect(page).to_not have_content('Old Beer')
  #   end
  # end

end
