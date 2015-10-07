require 'rails_helper'

feature 'fae_table_sort' do

  scenario 'save sort preferences in session', js: true do
    admin_login
    visit admin_releases_path

    # Ensure nothing is selected
    expect(page).to_not have_selector('th.tablesorter-headerAsc[data-column="2"]')

    page.find('.tablesorter-header-inner', text: 'Modified').click

    # After click, it should have header
    expect(page).to have_selector('th.tablesorter-headerAsc[data-column="2"]')

    # Go to a new page and come back
    visit new_admin_person_path
    visit admin_releases_path

    expect(page).to have_selector('th.tablesorter-headerAsc[data-column="2"]')
  end

end
