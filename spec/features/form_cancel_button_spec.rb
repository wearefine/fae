require 'spec_helper'

feature 'Form cancel button' do

  before(:each) do
    admin_login
  end

  scenario 'when clicked before changes', js: true do
    # Use an existing record to avoid draft behavior
    release = FactoryBot.create(:release, name: 'Test Release')
    visit edit_admin_release_path(release)
    
    click_link 'Cancel'

    expect(page.current_path).to eq(admin_releases_path)
    expect(page).to_not have_content('Your changes were not saved.')
  end

  scenario 'when clicked on new draft record', js: true do
    visit new_admin_release_path
    
    # The new action creates a draft and redirects to edit with draft=true
    # Clicking cancel on a draft shows a confirmation dialog and deletes the draft

    # puts page.find('#js-header-cancel')['outerHTML']
    
    # # Debug: check what JS handlers see
    # page.execute_script("console.log('deletePath:', $('#js-header-cancel').attr('data-delete-path'));")
    # page.execute_script("console.log('isDraft:', $('#js-header-cancel').attr('data-draft'));")

    accept_confirm do
      click_link 'Cancel'
    end

    # Wait for AJAX delete and navigation to complete
    eventually {
      expect(page.current_path).to eq(admin_releases_path)
    }
  end

  scenario 'when clicked after changes', js: true do
    ## TODO: update Judge version
    # fill_in('Name', with: 'something')
    # click_link 'Cancel'

    # expect(page.current_path).to eq(admin_releases_path)
    # expect(page).to have_content('Your changes were not saved.')
  end

end

# TODO: fix flickering test, occasionally returns:
# Failure/Error: Unable to find matching line from backtrace
#      RuntimeError:
#        Role 'super admin' does not exist in Fae::Role, run rake fae:seed_db
#      # ./app/controllers/fae/setup_controller.rb:50:in `check_roles'
# feature 'Nested Form cancel button' do

#   scenario 'when clicked with required', js: true do
#     release = FactoryBot.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
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
