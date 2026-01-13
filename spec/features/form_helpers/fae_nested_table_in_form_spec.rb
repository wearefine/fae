require 'spec_helper'

feature 'fae_nested_table inside main form' do

  scenario 'should allow adding new items', js: true do
    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    click_link 'Add List Item'
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'My New List Item'
      # People is a Chosen.js select, need to interact with it directly
      page.find('#list_item_people_chosen').click
      page.find('#list_item_people_chosen .active-result', text: 'Alice').click
      click_button('Save')
    end

    eventually {
      expect(page.find('#list_items table')).to have_content('My New List Item')
      expect(ListItem.all.count).to eq(1)
    }
  end

  scenario 'should allow editing existing item', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Original Item', people: 'Bob', static_page: page_instance)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    expect(page.find('#list_items table')).to have_content('Original Item')

    click_link list_item.name
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Updated Item'
      click_button('Save')
    end

    eventually {
      expect(page.find('#list_items table')).to have_content('Updated Item')
      expect(page.find('#list_items table')).to_not have_content('Original Item')
    }
  end

  scenario 'should allow deletion of item', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Delete Me', people: 'Charlie', static_page: page_instance)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    expect(page.find('#list_items table')).to have_content('Delete Me')

    page.find("tr#list_items_#{list_item.id} .js-delete-link").click

    eventually {
      expect(page.find('#list_items table')).to_not have_content('Delete Me')
    }
  end

  scenario 'nested form inputs should not trigger validation on parent form submit', js: true do
    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the nested form but leave it incomplete (missing required fields)
    click_link 'Add List Item'
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Test Item'
      # Deliberately leave 'People' empty - it's a required field on the nested form
    end

    # Cancel the nested form to close it
    within(:css, '.js-addedit-form-wrapper') do
      click_button('Cancel')
    end

    # Wait for nested form to close
    expect(page).to_not have_selector('.js-addedit-form-wrapper', visible: true)

    # Now submit the parent form - this should not trigger nested form validation
    within(:css, '.content-header') do
      click_button 'Save'
    end

    # Parent form should save successfully (redirects to content blocks index)
    eventually {
      expect(current_path).to eq('/admin/pages')
    }
  end

  scenario 'should prevent parent form saving when user hits cancel on nested form unsaved changes alert', js: true do
    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    click_link 'Add List Item'
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Unsaved Item'
    end

    within(:css, '.content-header') do
      click_button 'Save'
    end
    page.driver.browser.reject_js_confirms

    expect(page).to have_css('.js-addedit-form-wrapper')
  end

  scenario 'allows parent form saving when user hits continue on nested form unsaved changes alert', js: true do
    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    click_link 'Add List Item'
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Unsaved Item'
    end

    within(:css, '.content-header') do
      click_button 'Save'
    end
    page.driver.browser.accept_js_confirms

    eventually {
      expect(current_path).to eq('/admin/pages')
    }
  end

  scenario 'nested form submit button should be re-enabled when user cancels parent form save', js: true do
    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    click_link 'Add List Item'
    expect(page).to have_css('.js-addedit-form-wrapper')

    within(:css, '.js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Unsaved Item'
    end

    within(:css, '.content-header') do
      click_button 'Save'
    end
    page.driver.browser.reject_js_confirms

    # The nested form's Save button should be re-enabled
    eventually {
      within(:css, '.js-addedit-form-wrapper') do
        save_button = page.find('input[type="submit"], button[type="submit"]')
        expect(save_button).to_not be_disabled
      end
    }
  end

  scenario 'should allow adding items to double-nested table', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Parent Item', people: 'Diana', static_page: page_instance)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the parent nested item to see its sub-items
    within(:css, '#list_items') do
      click_link list_item.name
    end
    
    # Wait for the list_item form to load and show the sub_list_items section
    expect(page).to have_content('Add Sub List Item')

    click_link 'Add Sub List Item'
    
    # The sub_list_item form opens in a nested .nested-form div inside the list_item's form wrapper
    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper')

    within(:css, '#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper') do
      fill_in 'Name', with: 'My Sub Item'
      fill_in 'Body', with: 'Sub item body text'
      click_button('Save')
    end

    eventually {
      expect(page.find('#list_items .js-addedit-form-wrapper .nested-form table')).to have_content('My Sub Item')
      expect(SubListItem.all.count).to eq(1)
    }
  end

  scenario 'should allow editing items in double-nested table', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Parent Item', people: 'Diana', static_page: page_instance)
    sub_list_item = SubListItem.create!(name: 'Original Sub Item', body: 'Original body', list_item: list_item)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the parent nested item
    within(:css, '#list_items') do
      click_link list_item.name
    end
    
    # Wait for the sub_list_items table to appear inside the list_item's form wrapper
    expect(page).to have_css("tr#sub_list_items_#{sub_list_item.id}")
    expect(page).to have_content('Original Sub Item')

    # Open the sub item for editing by clicking on the table row link
    page.find("tr#sub_list_items_#{sub_list_item.id}").click_link(sub_list_item.name)
    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper')

    within(:css, '#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Updated Sub Item'
      click_button('Save')
    end

    eventually {
      expect(page.find('#list_items .js-addedit-form-wrapper .nested-form table')).to have_content('Updated Sub Item')
      expect(page.find('#list_items .js-addedit-form-wrapper .nested-form table')).to_not have_content('Original Sub Item')
    }
  end

  scenario 'should allow deletion of items in double-nested table', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Parent Item', people: 'Diana', static_page: page_instance)
    sub_list_item = SubListItem.create!(name: 'Delete This Sub Item', body: 'Body text', list_item: list_item)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the parent nested item
    within(:css, '#list_items') do
      click_link list_item.name
    end
    
    # Wait for the sub_list_items table to appear inside the list_item's form wrapper
    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form table')
    expect(page.find('#list_items .js-addedit-form-wrapper .nested-form table')).to have_content('Delete This Sub Item')

    page.find("tr#sub_list_items_#{sub_list_item.id} .js-delete-link").click

    eventually {
      expect(page.find('#list_items .js-addedit-form-wrapper .nested-form table')).to_not have_content('Delete This Sub Item')
    }
  end

  scenario 'double-nested form should prevent parent form saving when user hits cancel on unsaved changes alert', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Parent Item', people: 'Diana', static_page: page_instance)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the parent nested item
    within(:css, '#list_items') do
      click_link list_item.name
    end
    expect(page).to have_content('Add Sub List Item')

    click_link 'Add Sub List Item'
    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper')

    within(:css, '#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Unsaved Sub Item'
    end

    within(:css, '.content-header') do
      click_button 'Save'
    end
    page.driver.browser.reject_js_confirms

    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper')
  end

  scenario 'double-nested form allows parent form saving when user hits continue on unsaved changes alert', js: true do
    page_instance = NestedTablesInFormPage.instance
    list_item = ListItem.create!(name: 'Parent Item', people: 'Diana', static_page: page_instance)

    admin_login
    visit fae.edit_content_block_path('nested_tables_in_form')

    # Open the parent nested item
    within(:css, '#list_items') do
      click_link list_item.name
    end
    expect(page).to have_content('Add Sub List Item')

    click_link 'Add Sub List Item'
    expect(page).to have_css('#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper')

    within(:css, '#list_items .js-addedit-form-wrapper .nested-form .js-addedit-form-wrapper') do
      fill_in 'Name', with: 'Unsaved Sub Item'
    end

    within(:css, '.content-header') do
      click_button 'Save'
    end
    page.driver.browser.accept_js_confirms

    eventually {
      expect(current_path).to eq('/admin/pages')
    }
  end

end
