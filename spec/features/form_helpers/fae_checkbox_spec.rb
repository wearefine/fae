require 'spec_helper'

feature 'fae_checkbox' do

  scenario 'clicking label or checkbox should check box', js: true do
    FactoryGirl.create(:event)
    admin_login
    visit new_admin_release_path

    within('.release_events') do
      page.first('span.checkbox').find('label').click
      expect(page).to have_selector('label.js-active')

      page.first('span.checkbox').find('label').click
      expect(page).to_not have_selector('label.js-active')
    end
  end

  scenario 'clicking label or checkbox should check box', js: true do
    release = FactoryGirl.create(:release)
    aroma = FactoryGirl.create(:aroma, release: release, live: true )
    admin_login
    visit edit_admin_release_path(release)

    click_link(aroma.name)
    within('.js-addedit-form-wrapper') do
      page.first('span.checkbox').find('label').click
      expect(page).to have_selector('label.js-active')

      page.first('span.checkbox').find('label').click
      expect(page).to_not have_selector('label.js-active')
    end
  end

end
