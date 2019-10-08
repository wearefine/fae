require 'spec_helper'

def make_some_form_changes
  expect(page).to_not have_content('Name helper text')
  click_link('Manage Form')
  fill_in('Release_name_label_input', with: 'Name edited')
  fill_in('Release_name_helper_input', with: 'Name helper text')
  click_link('Manage Form')
  expect(page).to have_content('* Name edited')
  expect(page).to have_content('Name helper text')
end

feature 'Form Manager' do

  before(:each) do
    admin_login
    release = FactoryGirl.create(:release, name: '2012 Chardonnay')
    visit edit_admin_release_path(release.id)
  end

  # Standard main forms

  scenario 'form manager displays when launched, hides things, shows inputs', js: true do
    expect(page).to have_content('* Name')
    click_link('Manage Form')
    expect(page).to_not have_content('* Name')
    expect(page).to have_selector("input[value='Name']")
  end

  scenario 'form manager goes away and things show their new values', js: true do
    make_some_form_changes
  end

  scenario 'form manager saves changes to db and page requests show changes', js: true do
    make_some_form_changes
    visit new_admin_release_path
    expect(page).to have_content('* Name edited')
    expect(page).to have_content('Name helper text')
  end

  # Nested forms

  scenario 'form manager works for nested forms', js: true do
    release = FactoryGirl.create(:release, name: '2020 Vision')
    visit edit_admin_release_path(release.id)

    click_link('Add Release Note')
    within('.js-addedit-form-wrapper') do
      expect(page).to have_content('Title')

      click_link('Manage Form')
      expect(page).to have_selector("input[value='Title']")
      fill_in('ReleaseNote_title_label_input', with: 'Title edited')
      fill_in('ReleaseNote_title_helper_input', with: 'Title helper text')

      click_link('Manage Form')
      expect(page).to have_content('Title edited')
      expect(page).to have_content('Title helper text')
    end

    # Reload parent form and nested form
    visit edit_admin_release_path(release.id)
    click_link('Add Release Note')
    within('.js-addedit-form-wrapper') do
      expect(page).to have_content('Title edited')
      expect(page).to have_content('Title helper text')
    end
  end

  # Fae::StaticPage forms

  scenario 'form manager works for fae pages', js: true do
    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Email')

    click_link('Manage Form')
    fill_in('ContactUsPage_email_label_input', with: 'Email address')
    fill_in('ContactUsPage_email_helper_input', with: 'Email helper')

    click_link('Manage Form')
    expect(page).to have_content('Email address')
    expect(page).to have_content('Email helper')

    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Email address')
    expect(page).to have_content('Email helper')
  end

  # Multi language inputs

  scenario 'form manager works with fae languages feature', js: true do
    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Hero (en)')

    click_link('Manage Form')
    fill_in('ContactUsPage_hero_en_label_input', with: 'Hero (en) edited')
    fill_in('ContactUsPage_hero_en_helper_input', with: 'Hero (en) helper')

    click_link('Manage Form')
    expect(page).to have_content('Hero (en) edited')
    expect(page).to have_content('Hero (en) helper')

    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Hero (en) edited')
    expect(page).to have_content('Hero (en) helper')
  end

  # ignore_form_manager flag

  scenario 'form manager ignores fields flagged as ignore_form_manager: true', js: true do
    release = FactoryGirl.create(:release, name: 'A Release')
    visit edit_admin_release_path(release.id)
    expect(page).to have_content('Seo Title')

    click_link('Manage Form')
    expect(page).to_not have_selector("input[value='Seo Title']")
  end

end
