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
    expect(page).to have_css('#js-header-cancel[data-draft="true"]')
    eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }

    # An unload attempt is blocked until the user submits or confirms
    expect(unload_prevented?).to be true
  end

  scenario 'does not warn on unload for forms that are not drafts', js: true do
    release = FactoryBot.create(:release, name: 'Test Release')
    visit edit_admin_release_path(release)
    eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }

    expect(unload_prevented?).to be false
  end

  scenario 'allows unload after form submission', js: true do
    visit new_admin_release_path
    eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }
    expect(unload_prevented?).to be true

    # Trigger form submit event (doesn't need to actually submit)
    page.execute_script("$('form').first().on('submit', function(e) { e.preventDefault() }).trigger('submit')")

    expect(unload_prevented?).to be false
  end

  scenario 'adds the cancelled param after the form changes', js: true do
    release = FactoryBot.create(:release, name: 'Test Release')
    visit edit_admin_release_path(release)
    eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }

    fill_in 'release_name', with: 'Changed'

    expect(page).to have_css('#js-header-cancel[href$="?cancelled=true"]')
    fill_in 'release_name', with: 'Changed again'
    expect(page).to have_css('#js-header-cancel[href$="?cancelled=true"]')
    expect(page.find('#js-header-cancel')[:href]).to_not include('cancelled=true?cancelled=true')
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


  def unload_prevented?
    page.evaluate_script(<<~JS)
      (function() {
        var event = new Event('beforeunload', { cancelable: true });
        window.dispatchEvent(event);
        return event.defaultPrevented;
      })()
    JS
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
