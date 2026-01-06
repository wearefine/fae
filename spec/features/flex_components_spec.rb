require 'rails_helper'

RSpec.feature 'FlexComponents management', type: :feature do
  scenario 'User can CRUD flex components on FAE pages', js: true do
    admin_login
    visit fae.edit_content_block_path('components')
    
    # Select from the component dropdown (using Chosen)
    find('.js-component-select', visible: false).find(:option, 'Text', visible: false).select_option
    
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Test Component'
    within("form#edit_text_component_#{Fae::FlexComponent.first.id}") do
      click_on 'Save'
    end
    expect(page).to have_content('Test Component')

    # Edit/Update
    within('#components') do
      click_on 'Text'
    end
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Updated Component'
    within("form#edit_text_component_#{Fae::FlexComponent.first.id}") do
      click_on 'Save'
    end
    expect(page).to have_content('Updated Component')

    # Destroy
    accept_confirm do
      within('#components') do
        click_on(class: 'js-delete-link')
      end
      expect(page).to_not have_content('Updated Component')
    end
  end

  scenario 'User can CRUD flex components on regular models', js: true do
    admin_login
    red = FactoryBot.create(:wine, name_en: 'Red')
    visit edit_admin_wine_path(red)
    
    # Select from the component dropdown (using Chosen)
    find('.js-component-select', visible: false).find(:option, 'Text', visible: false).select_option
    
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Test Component'
    within("form#edit_text_component_#{Fae::FlexComponent.first.id}") do
      click_on 'Save'
    end
    expect(page).to have_content('Test Component')

    # Edit/Update
    within('#components') do
      click_on 'Text'
    end
    expect(page).to have_content('Edit Text Component')
    fill_in 'text_component_name', with: 'Updated Component'
    within("form#edit_text_component_#{Fae::FlexComponent.first.id}") do
      click_on 'Save'
    end
    expect(page).to have_content('Updated Component')

    # Destroy
    accept_confirm do
      within('#components') do
        click_on(class: 'js-delete-link')
      end
      expect(page).to_not have_content('Updated Component')
    end
  end
end