require 'spec_helper'

feature 'fae_input' do
  before(:each) do
    admin_login
    visit new_admin_release_path
  end

  scenario 'should display input, label, helper and classes' do
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

  scenario 'should display common helper texts' do
    expect(page).to have_content('A descriptive page title of ~50-65 characters. Displayed in search engine results.')
    expect(page).to have_content('A helpful page summary of 200 characters or less. Displayed in search engine results.')
  end

  scenario 'should display hint when clicked', js: true do
    expect(page).to_not have_content('Normal Hint')
    page.find('.release_vintage .hinter-clicker').trigger('click')
    expect(page).to have_content('Normal Hint')
  end

  scenario 'should hide label on hidden fields', js: true do
    within('.release_created_at') do
      expect(page).to_not have_content('Created at')
    end
  end

  scenario 'should have maximum characters on fields with maximum length validations', js: true do
    within('.release_name') do
      expect(page).to have_content('Maximum Characters: 15')
      fill_in "release_name", with: "My Release"
      expect(page).to have_content('Characters Left: 5')
    end
  end

  scenario 'should display markdown helper when markdown_supported: true', js: true do
    within('.release_body-text_area--wrapper') do
      expect(page).to have_selector('label .helper_text .markdown-support')
    end
  end

  scenario 'should display markdown WYSIWYG when markdown: true', js: true do
    within('.release_intro') do
      expect(page).to have_selector('.CodeMirror')
    end

    within('.release_content') do
      expect(page).to have_selector('.js-html-editor')
    end
  end

  scenario 'should display HTML WYSIWYG when html: true', js: true do
    within('.release_content') do
      expect(page).to have_selector('.js-html-editor')
    end
  end

  scenario 'should display markdown guide when support is clicked', js: true do
    expect(page).to_not have_selector('.markdown-hint-wrapper')

    page.find('.markdown-support').click

    expect(page).to have_selector('.markdown-hint-wrapper')
  end

  scenario 'should not allow character counts greater than 255 on string column text fields', js: true do
    within('.release_slug') do
      fill_in 'release_slug', with: 'The letter J wanted to be like all the other letters of the alphabet, but the other letters were very cruel. They said "The letter J, you look like a disheveled I. The letter I is cool." J countered, "There is no I in team." It was not a very good comeback, and everyone laughed, cruelly, at the letter J again, including the headmaster. The letter J was left out of the alphabet that day as well as this validation.'

      expect(find_field('Slug').value).to eq('The letter J wanted to be like all the other letters of the alphabet, but the other letters were very cruel. They said "The letter J, you look like a disheveled I. The letter I is cool." J countered, "There is no I in team." It was not a very good comebac')
    end
  end

end
