require 'spec_helper'

feature 'fae_multiselect' do

  scenario 'should use chosen multiselect by default', js: true do
    admin_login
    visit new_admin_release_path

    # wrapper_class
    expect(page).to have_css('div.release_acclaims')

    within('div.release_acclaims') do
      expect(page).to have_css('div.chosen-container.chosen-container-multi')
    end
  end

  scenario 'should display two-pane when `two_pane: true`', js: true do
    FactoryBot.create(:selling_point, name: 'new one')

    admin_login
    visit new_admin_release_path

    # wrapper_class
    within('div.release_selling_points') do
      expect(page).to have_css('div.ms-container div.ms-selectable')
      expect(page).to have_css('div.ms-container div.ms-selection')

      expect(page).to_not have_css('div.ms-selection', text: 'new one')
      page.find('div.ms-selectable .ms-elem-selectable').click
      expect(page).to have_css('div.ms-selection', text: 'new one')
    end
  end

  scenario 'should use label_method if set' do
    FactoryBot.create(:acclaim, publication: 'Bathroom Reader Monthly')

    admin_login
    visit new_admin_release_path

    expect(page).to have_content('Bathroom Reader Monthly')
  end

  scenario 'should only display a single "de-select all" option after rendering nested form', js: true do
    wine = FactoryBot.create(:wine)
    release = FactoryBot.create(:release, name: 'testy mctest') 
    release = FactoryBot.create(:release, name: 'testy mctest 2') 

    admin_login
    visit edit_admin_wine_path(wine)

    click_link 'Add Oregon Winemaker'
    expect(page).to have_css('form#new_winemaker')


    group = find 'div.select'
    group.click
    within(group) do
      find('li', text: 'testy mctest 2').click
    end

    eventually {
      expect(page).to have_selector('.js-multiselect-action-deselect_all', count: 1)
    }
  end

end
