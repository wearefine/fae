require 'spec_helper'

feature 'Sign Out' do

  scenario 'when user clicks log out', js: true do
    # TODO: this test is flickering, occasionally getting `Capybara::ElementNotFound: Unable to find link "Log Out"`
    # it's a test worth having, so we should look into it

    # admin_login

    # visit fae.root_path

    # find('.utility-nav-user').click

    # eventually {
    #   click_link 'Log Out'

    #   expect(page).to have_content('Goodbye for now.')
    #   expect(page).to have_content('Forgot your password?')
    # }
  end

end