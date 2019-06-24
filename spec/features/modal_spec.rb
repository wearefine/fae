require 'spec_helper'

feature 'modal' do

  scenario 'should display ajax modal popup when link is clicked', js: true do
    release = FactoryGirl.create(:release)
    aroma = FactoryGirl.create(:aroma, release: release, live: true )
    admin_login
    visit edit_admin_release_path(release)

    click_link(aroma.name)
    within('.js-addedit-form-wrapper', visible: false) do
      expect(page).to_not have_selector('#fae-modal')

      page.find('.js-fae-modal').click

      expect(page).to have_selector('label.active')
    end
  end

end
