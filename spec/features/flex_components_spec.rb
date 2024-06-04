require 'rails_helper'

RSpec.feature 'FlexComponents management', type: :feature do
  scenario 'User can CRUD flex components', js: true do
    admin_login
    visit fae.edit_content_block_path('component_page')
    click_on 'New Component'
    expect(page).to have_content('New Flex Component')
    
    # Enable the actual select element so we can test this stuff, trying to get the fancy select to work
    # with native Capybara methods isn't flying.
    page.execute_script("$('#flex_component_component_model').css({display: 'block', visibility: 'visible', position: 'static'}) ")
    
    select 'Text', from: 'flex_component_component_model'
    click_on 'Create Flex component'
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Test Component'
    click_on 'Update Text component'
    expect(page).to have_content('Test Component')

    # Edit/Update
    within('.js-sort-row') do
      click_on 'Text'
    end
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Updated Component'
    click_on 'Update Text component'
    expect(page).to have_content('Updated Component')

    # Destroy
    accept_confirm do
      within('.js-sort-row') do
        click_on(class: 'js-delete-link')
      end
      expect(page).to_not have_content('Updated Component')
    end
  end
end