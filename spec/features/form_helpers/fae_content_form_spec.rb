require 'spec_helper'

feature 'fae_content_form' do

  scenario 'should display content form fields, markdown class if its included, and custom input classes if they are included' do

    admin_login
    visit fae.edit_content_block_path('home')

    # helper_method
    expect(page).to have_css('#home_page_header_attributes_content')
    expect(page).to have_css('#home_page_introduction_attributes_content')

    # # input_class
    expect(page).to have_css('.phone-mask')

    # input_class + markdown
    within('.home_page_introduction_2_content') do
        expect(page).to have_selector('.js-markdown-editor')
    end

    # just markdown
    within('.home_page_body_content') do
        expect(page).to have_css('.some-cool-class')
        expect(page).to have_selector('.js-markdown-editor')
    end
  end

end