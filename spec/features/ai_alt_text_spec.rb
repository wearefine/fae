require 'rails_helper'

RSpec.feature 'Generate Alt Text', type: :feature do
  scenario 'User selects an image and generates alt text', js: true do
    admin_login
    visit new_admin_beer_path

    # Add the image to the image input
    page.execute_script("$('#beer_image_attributes_asset').css({visibility: 'visible', position: 'static'}) ")
    attach_file('beer_image_attributes_asset', 'spec/support/assets/test.jpg')

    find('span', text: 'Generate Alt', match: :first).click

    eventually {
      expect(page).to have_field('beer_image_attributes_alt', with: 'A playful beagle puppy is lying down and chewing on a dry leaf.')
    }
  end
end
