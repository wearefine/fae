require 'spec_helper'

feature 'fae_color_picker' do
  scenario 'opens color picker', js: true do
    admin_login
    visit new_admin_release_path

    expect(page).to_not have_selector('.cp-color-picker')
    page.find('#release_color').click
    expect(page).to have_selector('.cp-color-picker', visible: true)
    page.find('.content').click
    expect(page).to have_selector('.cp-color-picker', visible: false)
  end
end
