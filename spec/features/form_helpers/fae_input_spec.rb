require 'spec_helper'

feature 'fae_input' do

  scenario 'should display input, label, helper and classes' do
    admin_login
    visit new_admin_release_path

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
      expect(page).to have_content('Text Area wtih Hint Pop Up')
    end
  end

  # scenario 'should display hint', js: true do
  #   admin_login
  #   visit new_admin_release_path
  # end

end