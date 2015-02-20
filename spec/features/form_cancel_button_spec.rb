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
