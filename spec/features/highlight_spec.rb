require 'spec_helper'

feature 'Deploy Hooks' do

  scenario 'when user leaves out email', js: true do

    # Note: #8788EE is equal to rgb(135, 136,238)

    super_admin_login
    
    visit fae.option_path
    fill_in 'option_colorway', with: '8788EE'
    fill_in 'option_title', with: 'Title'
    fill_in 'option_live_url', with: 'http://www.wearefine.com'
    find(:xpath, "//*[@id='option_time_zone_chosen']").set '(GMT-08:00) Pacific Time (US & Canada)'

    click_button 'Save'

    eventually {
      visit fae.root_path
      test_rgb_color = "rgb(135, 136, 238)"
      set_rgb_color = find('header#js-main-header').evaluate_script("window.getComputedStyle(this)['border-top-color']")

      expect(set_rgb_color).to eq(test_rgb_color)
    }

  end

end
