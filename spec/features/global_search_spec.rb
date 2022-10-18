require 'spec_helper'

feature 'Global search' do

  scenario 'user interacts with the search', js: true do
    FactoryBot.create(:release, name: '2012 Chardonnay')
    FactoryBot.create(:release, name: '2013 Chardonnay')
    FactoryBot.create(:release, name: '2012 Merlot')
    FactoryBot.create(:team, name: 'The Sandlot Cats')

    admin_login
    visit fae_path

    within('#js-utility-search') do
      expect(page).to_not have_content('Products')

      # user hovers on the search icon
      first('a').hover
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

  # TODO: fix flickering test, occasionally returns:
  # 1) Global search search results get authorized
  #    Failure/Error: Unable to find matching line from backtrace
  #    RuntimeError:
  #      Role 'super admin' does not exist in Fae::Role, run rake fae:seed_db
  #    # ./app/controllers/fae/setup_controller.rb:50:in `check_roles'

  # see dummy app's authorization concern for auth mapping used here
  # scenario "search results get authorized", js: true do
  #   FactoryBot.create(:release, name: '2012 Chardonnay')
  #   FactoryBot.create(:person, name: 'Rupert')

  #   user_login
  #   visit fae_path

  #   within('#js-utility-search') do
  #     # user hovers on the search icon
  #     first('a').hover

  #     # doesn't see unauthorized stuff
  #     # object
  #     fill_in('js-global-search', with: 'char')
  #     expect(page).to_not have_content('2012 Chardonnay')
  #     # page
  #     fill_in('js-global-search', with: 'abou')
  #     expect(page).to_not have_content('About Us')

  #     # sees authorized stuff
  #     # object
  #     fill_in('js-global-search', with: 'rup')
  #     expect(page).to have_content('Rupert')
  #     # page
  #     fill_in('js-global-search', with: 'home')
  #     expect(page).to have_content('Home')
  #   end
  # end

end
