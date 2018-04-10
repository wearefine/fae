require 'rails_helper'

feature 'fae_table_sort' do

  # TODO: fix flickering test
  # scenario 'save sort preferences in session', js: true do
  #   FactoryGirl.create(:release)

  #   admin_login
  #   visit admin_releases_path

  #   # Ensure nothing is selected
  #   expect(page).to_not have_selector('.-asc[data-sort="updated_at"]')

  #   page.find('.th-sortable-title', text: 'Modified').click

  #   # After click, it should have header
  #   expect(page).to have_selector('.-asc[data-sort="updated_at"]')

  #   # Capybara need some time to set the cookie :/
  #   # can be found here: Capybara.current_session.driver.browser.get_cookies
  #   sleep 0.5

  #   # Go to a new page and come back
  #   visit new_admin_person_path
  #   visit admin_releases_path

  #   expect(page).to have_selector('.-asc[data-sort="updated_at"]')
  # end

end
