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

  scenario 'should have maximum characters on fields with maximum length validations', js: true do
    admin_login
    visit new_admin_release_path

    within('.release_name') do
      expect(page).to have_content('Maximum Characters: 15')
    end
  end

  scenario 'should have maximum characters on fields with maximum length validations', js: true do
    admin_login
    visit new_admin_release_path

    within('.release_name') do
      fill_in "release_name", with: "My Release"
      expect(page).to have_content('Characters Left: 5')
    end
  end

  scenario 'should display markdown helper when markdown_supported: true', js: true do
    admin_login
    visit new_admin_release_path

    within('.release_body-text_area--wrapper') do
      expect(page).to have_selector('label .helper_text .markdown-support')
    end
  end

  scenario 'should display markdown WYSIWYG when markdown: true', js: true do
    admin_login
    visit new_admin_release_path

    within('.release_intro') do
      expect(page).to have_selector('.CodeMirror')
    end
  end

  scenario 'should display markdown guide when support is clicked', js: true do
    admin_login
    visit new_admin_release_path

    expect(page).to_not have_selector('.markdown-hint-wrapper')

    page.find('.markdown-support').click

    expect(page).to have_selector('.markdown-hint-wrapper')
  end

end
