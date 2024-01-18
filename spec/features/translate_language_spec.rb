require 'spec_helper'

feature 'Language translation' do

  scenario 'translate button does not appear if options is not selected', js: true do
    admin_login
    visit fae.edit_content_block_path('privacy')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    expect(page).to_not have_selector('.js-translate-button')
  end

  scenario 'translate button appears if options is selected', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save
    visit fae.edit_content_block_path('privacy')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    within('.privacy_page_headline_frca_content')  { expect( page.find('.js-translate-button')) }
  end

  scenario 'text field translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('privacy')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click
    fill_in 'privacy_page_headline_en_attributes_content', with: 'Bob Ross is the man.'
    within('.privacy_page_headline_frca_content')  { page.find('.js-translate-button').click }

    sleep 0.5 # Needed to prevent race condition

    expect(page).to have_field('Headline (en)', with: 'Bob Ross is the man.')
    expect(page).to have_field('Headline (frca)', with: "Bob Ross est l'homme.")
  end

  scenario 'text area translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('privacy')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click
    fill_in 'privacy_page_body_2_en_attributes_content', with: 'Bob Ross is the man.'

    sleep 0.5 # Needed to prevent race condition

    within('.privacy_page_body_2_frca_content')  { page.find('.js-translate-button').click }
    expect(page).to have_field('Body 2 (en)', with: 'Bob Ross is the man.')
    expect(page).to have_field('Body 2 (frca)', with: "Bob Ross est l'homme.")
  end

  scenario 'text area with markdown translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('privacy')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    page.execute_script <<-JS
      const textArea = document.getElementById('privacy_page_body_en_attributes_content')
      $(textArea).data('editor').value('Bob Ross is the man.')
    JS

    sleep 0.5 # Needed to prevent race condition

    within('.privacy_page_body_frca_content')  { page.find('.js-translate-button').click }
    eventually {
      within('.privacy_page_body_en_content') { expect(find('.CodeMirror-code')).to have_content('Bob Ross is the man.') }
      within('.privacy_page_body_frca_content') { expect(find('.CodeMirror-code')).to have_content("Bob Ross est l'homme.") }
    }
  end
end
