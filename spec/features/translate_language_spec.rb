require 'spec_helper'

feature 'Language translation' do

  scenario 'translate button does not appear if options is not selected', js: true do
    admin_login
    visit fae.edit_content_block_path('home')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    expect(page).to_not have_selector('.js-translate-button')
  end

  scenario 'translate button appears if options is selected', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save
    visit fae.edit_content_block_path('home')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    within(".home_page_header_frca_content")  { expect( page.find('.js-translate-button')) }
  end

  scenario 'text field translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('home')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click
    fill_in 'home_page_header_en_attributes_content', with: 'Bob Ross is the man.'
    within(".home_page_header_frca_content")  { page.find('.js-translate-button').click }
    sleep 0.5
    expect(page).to have_field('Header (en)', with: "Bob Ross is the man.")
    expect(page).to have_field('Header (frca)', with: "Bob Ross est l'homme.")
  end

  scenario 'text area translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('home')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click
    fill_in 'home_page_introduction_en_attributes_content', with: 'Bob Ross is the man.'
    sleep 0.5
    within(".home_page_introduction_frca_content")  { page.find('.js-translate-button').click }
    expect(page).to have_field('Introduction (en)', with: "Bob Ross is the man.")
    expect(page).to have_field('Introduction (frca)', with: "Bob Ross est l'homme.")
  end

  scenario 'text area with markdown translates', js: true do
    admin_login
    option = Fae::Option.instance
    option.translate_language = true
    option.save

    visit fae.edit_content_block_path('home')

    page.find('#js_language_chosen').click
    page.find('#js_language_chosen li', text: 'French Canadian').click

    page.execute_script <<-JS
      const textArea = document.getElementById('home_page_introduction_2_en_attributes_content')
      $(textArea).data('editor').value('Bob Ross is the man.')
    JS

    sleep 0.5

    within(".home_page_introduction_2_frca_content")  { page.find('.js-translate-button').click }
    eventually {
      within(".home_page_introduction_2_frca_content") { expect(find('.CodeMirror-code')).to have_content("Bob Ross est l'homme.") }
    }
  end
end
