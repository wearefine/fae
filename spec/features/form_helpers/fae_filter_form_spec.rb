require 'spec_helper'

feature 'fae_filter_form' do
  scenario 'can reset search after keyword search', js: true do
    FactoryBot.create(:release, name: 'Release 1')
    FactoryBot.create(:release, name: 'Release 2')

    admin_login
    visit admin_releases_path
    expect(page).to_not have_css('.js-reset-btn')
    fill_in 'filter_search', with: 'Release 1'
    page.execute_script("$('.js-filter-form').submit()")

    expect(page).to have_css('.js-reset-btn')
    find('.js-reset-btn').click
    expect(page).to have_field('filter_search', with: '')
  end
end
