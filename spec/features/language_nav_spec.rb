require 'spec_helper'

feature 'Language nav' do

  scenario 'should add language data attrs to element wrappers' do
    admin_login
    visit new_admin_wine_path

    expect(page).to have_selector('.wine_name_en[data-language=en]')
  end

  scenario 'should not overwrite custom data attrs' do
    admin_login
    visit new_admin_wine_path

    expect(page).to have_selector('.wine_name_en[data-test="do not overwrite me"]')
  end

  scenario 'should not overwrite custom wrapper class' do
    admin_login
    visit new_admin_wine_path

    expect(page).to have_selector('.wine_name_en.test-class')
  end

  scenario 'selecting a language toggle should only show those language fields', js: true do
    admin_login
    visit new_admin_wine_path

    # Open the chosen menu
    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'English').click
    expect(page).to     have_selector('div[data-language=en]')
    expect(page).to_not have_selector('div[data-language=ja]')

    # Open the chosen menu
    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'Japanese').click
    expect(page).to     have_selector('div[data-language=ja]')
    expect(page).to_not have_selector('div[data-language=en]')
  end

  # spec is causing issues in appraisal, AJAX call to update current_user.language is not sticking
  scenario 'language preferences should be saved to the user', js: true do
    # admin_login
    # visit new_admin_wine_path

    # Open the chosen menu
    # page.find('#js_language_chosen').click
    # page.find('#js_language_chosen li', text: 'Japanese').click
    # visit new_admin_wine_path
    # expect(page).to     have_selector('div[data-language=ja]')
    # expect(page).to_not have_selector('div[data-language=en]')

    # page.find('#js_language_chosen').click
    # page.find('#js_language_chosen li:first-child').click
    # visit new_admin_wine_path
    # expect(find('#js_language_chosen li.result-selected')).to have_content('All Languages')
  end

end
