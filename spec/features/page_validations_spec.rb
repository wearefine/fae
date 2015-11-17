require 'spec_helper'

feature 'page validations' do

  context 'on Fae::TextFields' do

    scenario 'should add an asterik to required fields' do
      admin_login
      visit fae.edit_content_block_path('home')

      expect(page).to have_content('* Header')
    end

    scenario 'should validate presence on blur', js: true do
      home_page = HomePage.instance
      home_page.create_header(content: 'test')

      admin_login
      visit fae.edit_content_block_path('home')

      page.find('#home_page_header_attributes_content').trigger('focus')
      fill_in 'home_page_header_attributes_content', with: ''
      page.find('#home_page_header_attributes_content').trigger('blur')

      expect(page).to have_selector('#home_page_header_attributes_content.invalid')
      expect(page).to have_selector('div.home_page_header_content.field_with_errors')
      expect(page).to have_selector('div.home_page_header_content span.error')

      page.find('#home_page_header_attributes_content').trigger('focus')
      fill_in 'home_page_header_attributes_content', with: 'something'
      page.find('#home_page_header_attributes_content').trigger('blur')

      expect(page).to_not have_selector('#home_page_header_attributes_content.invalid')
      expect(page).to_not have_selector('div.home_page_header_content.field_with_errors')
      expect(page).to_not have_selector('div.home_page_header_content span.error')
    end

    scenario 'should validate presence on form submission', js: true do
      admin_login
      visit fae.edit_content_block_path('home')
      click_button('Save Settings')

      expect(page).to have_selector('div.home_page_header_content.field_with_errors')
      expect(page).to have_selector('div.home_page_header_content span.error')
    end

    scenario 'should validate format on blur', js: true do
      admin_login
      visit fae.edit_content_block_path('home')

      page.find('#home_page_email_attributes_content').trigger('focus')
      fill_in 'home_page_email_attributes_content', with: 'not an email'
      page.find('#home_page_email_attributes_content').trigger('blur')

      expect(page).to have_selector('#home_page_email_attributes_content.invalid')
      expect(page).to have_selector('div.home_page_email_content.field_with_errors')
      expect(page).to have_selector('div.home_page_email_content span.error')

      page.find('#home_page_email_attributes_content').trigger('focus')
      fill_in 'home_page_email_attributes_content', with: 'legit@email.com'
      page.find('#home_page_email_attributes_content').trigger('blur')

      expect(page).to_not have_selector('#home_page_email_attributes_content.invalid')
      expect(page).to_not have_selector('div.home_page_email_content.field_with_errors')
      expect(page).to_not have_selector('div.home_page_email_content span.error')
    end

  end

  context 'on Fae::TextAreas' do

    scenario 'should add an asterik to required fields' do
      admin_login
      visit fae.edit_content_block_path('home')

      expect(page).to have_content('* Introduction')
    end

    scenario 'should validate presence on blur', js: true do
      home_page = HomePage.instance
      home_page.create_introduction(content: 'test')

      admin_login
      visit fae.edit_content_block_path('home')
      page.find('#home_page_introduction_attributes_content').trigger('focus')
      fill_in 'home_page_introduction_attributes_content', with: ''
      page.find('#home_page_introduction_attributes_content').trigger('blur')

      expect(page).to have_selector('#home_page_introduction_attributes_content.invalid')
      expect(page).to have_selector('div.home_page_introduction_content.field_with_errors')
      expect(page).to have_selector('div.home_page_introduction_content span.error')
    end

    scenario 'should validate presence on form submission', js: true do
      admin_login
      visit fae.edit_content_block_path('home')
      click_button('Save Settings')

      expect(page).to have_selector('div.home_page_introduction_content.field_with_errors')
      expect(page).to have_selector('div.home_page_introduction_content span.error')
    end

    scenario 'should validate length on inline', js: true do
      home_page = HomePage.instance
      home_page.create_introduction(content: 'test')

      admin_login
      visit fae.edit_content_block_path('home')

      within(:css, 'div.home_page_introduction_content') do
        expect(page.find(:css, 'span.characters-left').text).to eq('Characters Left: 96')
        fill_in 'home_page_introduction_attributes_content', with: 'Add a couple more...'
        expect(page.find(:css, 'span.characters-left').text).to eq('Characters Left: 80')
        fill_in 'home_page_introduction_attributes_content', with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pulvinar euismod nisl, in pellentesque sapien ornare ac. Ut mattis vel elit id gravida. Nulla interdum rhoncus ante, eget congue nisi congue laoreet. Mauris finibus sagittis lacus, id condimentum metus dictum id. Aenean vel libero vel nibh ultrices pretium in non felis. Nullam eu mattis sem. Phasellus vehicula quam leo, a malesuada ex lobortis nec. Sed ac augue venenatis, vestibulum eros quis, venenatis tellus. Duis semper erat vel tempus accumsan. Nulla convallis justo aliquet aliquet sagittis. Aliquam eleifend arcu magna, ac convallis massa pulvinar nec.'
        expect(page.find(:css, 'span.characters-left').text).to include('Characters Over')
      end
    end


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

      within('.about_us_page_body_content') do
        expect(page).to have_selector('label .helper_text .markdown-support')
      end
    end
  end

end
