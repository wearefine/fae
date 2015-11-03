require 'spec_helper'

feature 'Sign Out' do

  scenario 'when user clicks log out', js: true do
    admin_login

    visit fae.root_path

    find('.utility_nav-user').click

    eventually {
      click_link 'Log Out'

      expect(page).to have_content('Goodbye for now.')
      expect(page).to have_content('Forgot your password?')
    }
  end

end