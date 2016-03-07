require 'rails_helper'

feature 'fae_table_collapse' do

  scenario 'should open collapsed table when the header is clicked', js: true do
    admin_login
    visit admin_events_path

    # Ensure collapsed table is collapsed
    expect(page).to_not have_selector('#first-table table')

    page.find('#first-table h3').click

    # Ensure collapsed table expands
    expect(page).to have_selector('#first-table table')
  end

  scenario 'should open or close all tables when all toggle is clicked', js: true do
    admin_login
    visit admin_events_path

    # Ensure collapsed tables are collapsed
    expect(page).to_not have_selector('.collapsible table')

    page.find('.collapsible-toggle').click

    # Ensure all collapsed tables expands
    expect(page).to have_selector('.collapsible table:not(.sticky-table-header--hidden)', count: 4)

    page.find('.collapsible-toggle').click

    expect(page).to_not have_selector('.collapsible table')
  end

  scenario 'should not have collapsible options when there is only one collapsible table', js: true do
    admin_login
    visit admin_selling_points_path

    # Ensure collapsed tables are collapsed
    expect(page).to_not have_selector('.collapsible')
    expect(page).to_not have_selector('.collapsible-toggle')
  end

end
