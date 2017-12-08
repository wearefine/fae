require 'spec_helper'

feature 'fae_content_form' do

  scenario 'should display content form fields, markdown class, custom input classes, and allow blank labels' do

    admin_login
    visit fae.edit_content_block_path('home')

    # helper_method
    expect(page).to have_css('#home_page_header_attributes_content')
    expect(page).to have_css('#home_page_introduction_attributes_content')

    # # input_class/wrapper_class
    expect(page).to have_css('.phone-mask')
    expect(page).to have_selector('.phone-wrapper')
    expect(page).to have_selector('#phone-id')

    # input_class + markdown + helper_text
    within('.home_page_introduction_2_content') do
      expect(page).to have_selector('.js-markdown-editor')
      expect(page).to have_content('helper text')
    end

    # just markdown
    within('.home_page_body_content') do
      expect(page).to have_css('.some-cool-class')
      expect(page).to have_selector('.js-markdown-editor')
    end

    # blank labels
    within('.home_page_cell_phone_content') do
      expect(page).to_not have_css('label')
    end

    within('.home_page_work_phone_content') do
      expect(page).to_not have_css('label')
    end
  end

end
