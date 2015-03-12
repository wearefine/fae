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
    FactoryGirl.create(:selling_point, name: 'new one')

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
    FactoryGirl.create(:acclaim, publication: 'Bathroom Reader Monthly')

    admin_login
    visit new_admin_release_path

    expect(page).to have_content('Bathroom Reader Monthly')
  end

end
