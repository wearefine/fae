require 'spec_helper'

feature 'Redirect to edit after create' do

  context 'after creating new record' do

    scenario 'should open the edit form for a new draft, then return to the index on save', js: true do
      admin_login
      visit new_admin_beer_path

      beer = Beer.last
      expect(beer.draft).to eq(true)
      expect(current_path).to eq(edit_admin_beer_path(beer))

      fill_in('Name', with: 'A Beer')
      click_button 'Save'

      # support/async_helper.rb
      eventually {
        expect(current_path).to eq(admin_beers_path)
      }
      expect(beer.reload.draft).to eq(false)
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
