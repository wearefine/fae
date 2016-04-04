require 'spec_helper'

feature 'Global search' do

  scenario 'user interacts with the search', js: true do
    FactoryGirl.create(:release, name: '2012 Chardonnay')
    FactoryGirl.create(:release, name: '2013 Chardonnay')
    FactoryGirl.create(:release, name: '2012 Merlot')
    FactoryGirl.create(:team, name: 'The Sandlot Cats')

    admin_login
    visit fae_path

    within('.utility-search') do
      expect(page).to_not have_content('Products')

      # user clicks the search icon
      first('a').click
      # expect the first to levels of nav
      expect(page).to have_content('Products')
      expect(page).to have_content('Wines')
      expect(page).to_not have_content('Varietals')

      # user enters 2 characters
      fill_in('js-global-search', with: 'ch')
      # expect nothing to change
      expect(page).to have_content('Products')

      # some searches and expected resuls
      fill_in('js-global-search', with: 'cat')
      expect(page).to have_content('The Sandlot Cats')
      expect(page).to have_content('Cats')
      expect(page).to have_content('Locations')
    end
  end

end
