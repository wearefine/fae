require 'spec_helper'

feature 'Form cancel button' do

  before(:each) do
    admin_login
    visit new_admin_release_path
  end

  scenario 'when clicked before changes', js: true do
    click_link 'Cancel'

    expect(page.current_path).to eq(admin_releases_path)
    expect(page).to_not have_content('Your changes were not saved.')
  end

  scenario 'when clicked after changes', js: true do
    fill_in('release_name', with: 'something')
    click_link 'Cancel'

    expect(page.current_path).to eq(admin_releases_path)
    expect(page).to have_content('Your changes were not saved.')
  end

end

# TODO: fix flickering test, occasionally returns:
# Failure/Error: Unable to find matching line from backtrace
#      RuntimeError:
#        Role 'super admin' does not exist in Fae::Role, run rake fae:seed_db
#      # ./app/controllers/fae/setup_controller.rb:50:in `check_roles'

# feature 'Nested Form cancel button' do

#   scenario 'when clicked with required', js: true do
#     release = FactoryGirl.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
#     admin_login
#     visit edit_admin_release_path(release)

#     # open nested form, then cancel
#     click_link('Add Aroma')
#     page.find('.cancel-nested-button').click

#     # save parent changes
#     click_button('Save')

#     expect(page).to_not have_content('Your changes were not saved.')
#   end

# end
