require 'spec_helper'

# 2024-04-29 This test is flickering. I've confirmed the behavior being tested is working as expected
# in the dummy app. The database_cleaner is truncating the fae_users table in the middle of the test so
# when the Save button is clicked, the `before_action :first_user_check` is getting hit and the 
# Fae::Option record never saves.
# Searching the web has revealed other people hitting this behavior with no functional solution that
# I've been able to reproduce.

feature 'Highlight Color' do

  scenario 'when user changes highlight color', js: true do

    super_admin_login
    visit fae.option_path
    fill_in 'option_colorway', with: '8788EE'
    fill_in 'option_title', with: 'Title'
    fill_in 'option_live_url', with: 'http://www.wearefine.com'
    find(:xpath, "//*[@id='option_time_zone_chosen']").set '(GMT-08:00) Pacific Time (US & Canada)'
    click_button 'Save'

    eventually {
      visit fae.root_path
      element = find('header#js-main-header')
      # rgb(135, 136,238) is the computed value for hex '#8788EE'
      expect(element.matches_style?('border-top-color': 'rgb(135, 136, 238)')).to eq(true)
    }

  end

end
