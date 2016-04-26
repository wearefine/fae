require 'spec_helper'

feature 'fae_image_form' do

  scenario 'should display updloader with alt by default', js: true do
    admin_login
    visit new_admin_release_path

    expect(page).to have_css('.release_bottle_shot_asset button.button')
    expect(page).to have_css('#release_bottle_shot_attributes_alt')
  end

end
