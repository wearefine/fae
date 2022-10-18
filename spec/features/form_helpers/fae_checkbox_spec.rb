require 'spec_helper'

feature 'fae_checkbox' do

  scenario 'clicking label or checkbox should check box', js: true do
    FactoryBot.create(:event)
    admin_login
    visit new_admin_release_path

    within('.release_events') do
      page.first('span.checkbox').find('label').click
      expect(page).to have_selector('label.active')

      page.first('span.checkbox').find('label').click
      expect(page).to_not have_selector('label.active')
    end
  end

  scenario 'clicking label or checkbox should check box', js: true do
    release = FactoryBot.create(:release)
    aroma = FactoryBot.create(:aroma, release: release, live: true )
    admin_login
    visit edit_admin_release_path(release)

    click_link(aroma.name)
    within('.js-addedit-form-wrapper') do
      expect(page).to have_selector('label.active')
    end
  end

  scenario 'clicking disabled checkbox has no effect', js: true do
    person = FactoryBot.create(:person)
    admin_login

    visit edit_admin_person_path(person)

    page.first('.boolean').find('label').click
    expect(page).to_not have_selector('label.active')
  end

end
