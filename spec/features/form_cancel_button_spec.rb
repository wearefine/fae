require 'spec_helper'

feature 'Form cancel button' do

  scenario 'when clicked before changes', js: true do
    admin_login
    visit new_admin_release_path

    click_link 'Cancel'

    expect(page.current_path).to eq(admin_releases_path)
    expect(page).to_not have_content('Your changes were not saved.')
  end

  scenario 'when clicked after changes', js: true do
    admin_login
    visit new_admin_release_path

    fill_in('Name', with: 'something')
    click_link 'Cancel'

    expect(page.current_path).to eq(admin_releases_path)
    expect(page).to have_content('Your changes were not saved.')
  end

end

feature 'Nested Form cancel button' do

  scenario 'when clicked with required', js: true do
    release = FactoryGirl.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
    admin_login
    visit edit_admin_release_path(release)

    # open nested form, then cancel
    click_link('Add Aroma')
    page.find('.cancel-nested-button').click

    # save parent changes
    click_button('Save Settings')

    expect(page).to_not have_content('Your changes were not saved.')
  end

end
