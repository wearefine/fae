require 'spec_helper'

def make_some_form_changes
  expect(page).to_not have_content('Name helper text')
  click_link('Manage Form')
  fill_in('Release_name_label_input', with: 'Name edited')
  fill_in('Release_name_helper_input', with: 'Name helper text')
  click_link('Submit')
  expect(page).to have_content('* Name edited')
  expect(page).to have_content('Name helper text')
end

feature 'Form Manager' do

  before(:each) do
    admin_login
    release = FactoryGirl.create(:release, name: '2012 Chardonnay')
    visit edit_admin_release_path(release.id)
  end

  # Standard main forms.

  scenario 'form manager displays when launched, hides things, shows inputs', js: true do
    expect(page).to have_content('* Name')
    click_link('Manage Form')
    expect(page).to_not have_content('* Name')
    expect(page).to have_selector("input[value='Name']")
  end

  scenario 'form manager goes away and things show their new values', js: true do
    expect(page).to_not have_content('Name helper text')
    click_link('Manage Form')

    fill_in('Release_name_label_input', with: 'Name edited')
    fill_in('Release_name_helper_input', with: 'Name helper text')
    fill_in('Release_hero_image_label_input', with: 'Hero Image edited')
    fill_in('Release_hero_image_helper_input', with: 'Hero Image helper text edited')
    fill_in('Release_label_pdf_label_input', with: 'Label Pdf Edited')
    fill_in('Release_label_pdf_helper_input', with: 'Label Pdf helper text Edited')

    click_link('Submit')

    eventually {
      expect(page).to have_content('* Name edited')
      expect(page).to have_content('Name helper text')
      expect(page).to have_content('Hero Image edited')
      expect(page).to have_content('Hero Image edited Caption')
      expect(page).to have_content('Hero Image edited Alt Text')
      expect(page).to have_content('Hero Image helper text edited')
      expect(page).to have_content('Label Pdf Edited')
      expect(page).to have_content('Label Pdf helper text Edited')

      # New stuff is persisted across page loads
      page.evaluate_script 'window.location.reload()'
      expect(page).to have_content('* Name edited')
      expect(page).to have_content('Name helper text')
      expect(page).to have_content('Hero Image edited')
      expect(page).to have_content('Hero Image helper text edited')
      expect(page).to have_content('Label Pdf Edited')
      expect(page).to have_content('Label Pdf helper text Edited')

      # Checkboxes inside labels don't get mangled
      expect(page).to have_selector("input[name='release[is_something]']")
    }
  end

  # Nested forms

  scenario 'form manager works for nested forms', js: true do
    release = FactoryGirl.create(:release, name: '2020 Vision')
    visit edit_admin_release_path(release.id)

    click_link('Add Release Note')
    within('.js-addedit-form-wrapper') do
      click_link('Manage Form')
    end
    expect(page).to have_selector("input[value='Title']")
    fill_in('ReleaseNote_title_label_input', with: 'Title edited')
    fill_in('ReleaseNote_title_helper_input', with: 'Title helper text')

    click_link('Submit')
    expect(page).to have_content('Title edited')
    expect(page).to have_content('Title helper text')

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
    fill_in('ContactUsPage_email_label_input', with: 'Email edited')
    fill_in('ContactUsPage_email_helper_input', with: 'Email helper')

    click_link('Submit')
    eventually {
      expect(page).to have_content('Email edited')
      expect(page).to have_content('Email helper')
    }

    visit fae.edit_content_block_path('contact_us')
    eventually {
      expect(page).to have_content('Email edited')
      expect(page).to have_content('Email helper')
    }
  end

  # Multi language inputs

  scenario 'form manager works with fae languages feature', js: true do
    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Hero (en)')

    click_link('Manage Form')
    fill_in('ContactUsPage_hero_en_label_input', with: 'Hero (en) edited')
    fill_in('ContactUsPage_hero_en_helper_input', with: 'Hero (en) helper')

    click_link('Submit')
    expect(page).to have_content('Hero (en) edited')
    expect(page).to have_content('Hero (en) helper')

    visit fae.edit_content_block_path('contact_us')
    expect(page).to have_content('Hero (en) edited')
    expect(page).to have_content('Hero (en) helper')
  end

  # ignore field functionality

  scenario 'form manager ignores fields flagged as show_form_manager: false', js: true do
    release = FactoryGirl.create(:release, name: 'A Release')
    visit edit_admin_release_path(release.id)
    expect(page).to have_content('Slug')
    expect(page).to have_content('Seo Title')

    click_link('Manage Form')
    # Via fae_input argument
    expect(page).to_not have_selector("input[value='Slug']")
    # Via presets in form_manager JS
    expect(page).to_not have_selector("input[value='Seo Title']")
  end

end
