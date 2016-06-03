require 'spec_helper'

feature 'page fields' do

  scenario 'should include all language fields' do
    admin_login
    visit fae.edit_content_block_path('about_us')

    expect(page).to have_selector('.about_us_page_body_zh_content')
    expect(page).to have_selector('.about_us_page_header_image_en_alt')
  end

  context 'on Fae::TextAreas' do
    scenario 'should display markdown WYSIWYG when markdown: true', js: true do
      admin_login
      visit fae.edit_content_block_path('about_us')

      within('.about_us_page_introduction_content') do
        expect(page).to have_selector('.CodeMirror')
      end
    end

    scenario 'should display markdown helper when markdown_supported: true', js: true do
      admin_login
      visit fae.edit_content_block_path('about_us')

      within('.about_us_page_body_en_content') do
        expect(page).to have_selector('label .helper_text .markdown-support')
      end

      # Options should carry through to international fields
      within('.about_us_page_body_zh_content') do
        expect(page).to have_selector('label .helper_text .markdown-support')
      end
    end
  end

end
