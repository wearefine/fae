require 'spec_helper'

feature 'Deploy' do

  before(:each) do
    admin_login
    FactoryBot.create(:fae_deploy_hook, environment: 'Production')
    FactoryBot.create(:fae_deploy_hook, environment: 'Staging')
    FactoryBot.create(:fae_deploy_hook, environment: 'Development')
  end

  # test drawing both tables

  scenario 'draws buttons', js: true do
    visit fae.deploy_path
    expect(page).to have_button('Deploy Production', disabled: true)
    expect(page).to have_button('Deploy Staging', disabled: true)
    expect(page).to have_button('Deploy Development', disabled: true)
  end

  scenario 'draws deploying table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('DEPLOYING')
    expect(page).to have_content('Staging building')
    expect(page).to have_content('10/22/2021 2:57 pm')
    expect(page).to have_content('00:01:33')
  end

  scenario 'draws past deploys table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('PAST DEPLOYS')
    expect(page).to have_content('FINE dev update')
    expect(page).to have_content('FINE admin triggered a Staging build')
    expect(page).to have_content('An error occurred. Please contact your FINE team.')
  end

  # Feature TBD
  # scenario 'loads changes tables', js: true do
  #   FactoryBot.create(:beer, name: 'New Beer')
  #   old_beer = FactoryBot.create(:beer, name: 'Old Beer')
  #   old_beer.tracked_changes.first.update_columns(updated_at: DateTime.new(2020, 10, 20))

  #   visit fae.deploy_path

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
