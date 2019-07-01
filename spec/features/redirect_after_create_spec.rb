require 'spec_helper'

feature 'Redirect to edit after create' do

  context 'after creating new record' do

    scenario 'should redirect to edit page', js: true do
      admin_login
      visit new_admin_beer_path
      fill_in('Name', with: 'A Beer')
      click_button 'Save'

      # support/async_helper.rb
      eventually {
        expect(current_path).to eq(edit_admin_beer_path(Beer.first))
      }
    end

    scenario 'should redirect to index page', js: true do
      admin_login
      visit new_admin_location_path
      fill_in('Name', with: 'A Location')
      click_button 'Save'

      # support/async_helper.rb
      eventually {
        expect(current_path).to eq(admin_locations_path)
      }
    end

  end

end
