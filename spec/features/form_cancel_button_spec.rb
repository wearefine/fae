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

  scenario 'sets up beforeunload handler on draft forms', js: true do
    visit new_admin_release_path
    
    # The new action creates a draft and redirects to edit with draft=true
    # Check that the beforeunload handler is registered
    
    # Verify the draft data attribute is set
    expect(page).to have_css('#js-header-cancel[data-draft="true"]')
    
    # Verify the beforeunload handler is attached by checking allowUnload flag exists
    has_handler = page.evaluate_script('typeof Fae.form.cancel.allowUnload !== "undefined"')
    expect(has_handler).to be true
    
    # Verify allowUnload is initially false (blocking navigation)
    allow_unload = page.evaluate_script('Fae.form.cancel.allowUnload')
    expect(allow_unload).to be false
  end
  
  scenario 'sets allowUnload to true on form submission', js: true do
    visit new_admin_release_path
    
    # Verify allowUnload starts as false
    allow_unload = page.evaluate_script('Fae.form.cancel.allowUnload')
    expect(allow_unload).to be false
    
    # Trigger form submit event (doesn't need to actually submit)
    page.execute_script("$('form').trigger('submit')")
    
    # Verify allowUnload is now true
    allow_unload = page.evaluate_script('Fae.form.cancel.allowUnload')
    expect(allow_unload).to be true
  end

  scenario 'allows navigation after form submission on draft', js: true do
    wine = FactoryBot.create(:wine, name_en: 'Test Wine')
    visit new_admin_release_path
    
    # Fill in required fields
    fill_in 'release_name', with: 'Test Release'
    
    # Select wine using Chosen dropdown (required)
    page.find('#release_wine_id_chosen').click
    page.find('#release_wine_id_chosen .active-result', text: wine.name_en).click
    
    # Fill in release_date using JS (required)
    page.execute_script("$('#release_release_date').val('#{Date.today}')")
    
    click_button 'Save'
    
    # After successful save, should navigate without warning
    eventually {
      expect(page.current_path).to eq(admin_releases_path)
    }
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
