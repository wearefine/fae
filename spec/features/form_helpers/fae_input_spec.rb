require 'spec_helper'

feature 'fae_input' do

  scenario 'should display input, label, helper and classes' do
    admin_login
    visit new_admin_release_path

    # label
    within('div.release_body-text_area--wrapper label') do
      expect(page).to have_content('Body Content')
    end
    # wrapper_class
    expect(page).to have_css('div.release_body-text_area--wrapper')
    # input_class
    expect(page).to have_css('textarea.release_body-text_area')
    # helper_method
    within('div.release_body-text_area--wrapper h6') do
      expect(page).to have_content('textarea')
    end
  end

  scenario 'should display hint when clicked', js: true do
    admin_login
    visit new_admin_release_path

    expect(page).to_not have_content('Normal Hint')
    page.find('.release_name .hinter-clicker').click
    expect(page).to have_content('Normal Hint')
  end

  scenario 'should display dark hint when clicked', js: true do
    admin_login
    visit new_admin_release_path

    expect(page).to_not have_content('Dark Hint')
    page.find('.release_vintage .hinter-clicker').click
    expect(page).to have_content('Dark Hint')
  end

  scenario 'should hide label on hidden fields', js: true do
    admin_login
    visit new_admin_release_path

    within('.release_created_at') do
      expect(page).to_not have_content('Created at')
    end
  end

end