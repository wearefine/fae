require 'rails_helper'

feature 'fae_table_sort' do

  # TODO: fix cookies and add tests
  # scenario 'save sort preferences in session', js: true do
  #   FactoryGirl.create(:release)

  #   admin_login
  #   visit admin_releases_path

  #   # Ensure nothing is selected
  #   expect(page).to_not have_selector('th.tablesorter-headerAsc[data-column="4"]')

  #   page.find('.tablesorter-header-inner', text: 'Modified').click

  #   # After click, it should have header
  #   expect(page).to have_selector('th.tablesorter-headerAsc[data-column="4"]')

  #   # Go to a new page and come back
  #   visit new_admin_person_path
  #   visit admin_releases_path

  #   expect(page).to have_selector('th.tablesorter-headerAsc[data-column="4"]')
  # end

end
