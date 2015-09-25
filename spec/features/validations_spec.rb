require 'spec_helper'

feature 'validations' do

  scenario 'inputs should validate on blur', js: true do
    admin_login
    visit new_admin_release_path
    page.find('#release_name').trigger('focus')
    page.find('#release_name').trigger('blur')

    expect(page).to have_selector('#release_name.invalid')
    expect(page).to have_selector('div.release_name.field_with_errors')
    expect(page).to have_selector('div.release_name span.error')
  end

  scenario 'inputs should validate on form submission', js: true do
    admin_login
    visit new_admin_release_path
    click_button('Save Settings')

    expect(page).to have_selector('#release_name.invalid')
    expect(page).to have_selector('div.release_name.field_with_errors')
    expect(page).to have_selector('div.release_name span.error')
  end

  scenario 'datapickers should validate on blur', js: true do
    admin_login
    visit new_admin_release_path
    page.find('#release_release_date').trigger('focus')
    page.find('#release_release_date').trigger('blur')

    expect(page).to have_selector('#release_release_date.invalid')
    expect(page).to have_selector('div.release_release_date.field_with_errors')
    expect(page).to have_selector('div.release_release_date span.error')
  end

  scenario 'selects should validate on change', js: true do
    wine = FactoryGirl.create(:wine)

    admin_login
    visit new_admin_release_path

    within('.release_wine') do
      page.find('.chosen-single').click
      page.find('li', text: wine.name_en).click
    end

    expect(page).to_not have_selector('div.release_wine.field_with_errors')
    expect(page).to_not have_selector('div.release_wine span.error')

    within('.release_wine') do
      page.find('.chosen-single').click
      page.find('li', text: 'Select One').click
    end

    expect(page).to have_selector('div.release_wine.field_with_errors')
    expect(page).to have_selector('div.release_wine span.error')
  end

end
