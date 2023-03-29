require 'spec_helper'

feature 'modal' do

  before(:each) do
    release = FactoryBot.create(:release)
    aroma = FactoryBot.create(:aroma, release: release, live: true )
    admin_login
    visit edit_admin_release_path(release)
    click_link(aroma.name)
  end

  scenario 'should display ajax modal popup when link is clicked', js: true do

    within('.js-addedit-form-wrapper') do
      expect(page).to_not have_selector('#fae-modal')

      page.find('.js-fae-modal').click

      eventually {
        # TODO: expect modal to be open
        # expect(page).to have_selector('#fae-modal')
        expect(page).to have_selector('.modal-callback--show')
        expect(page).to have_selector('.modal-callback--shown')
      }
    end
  end

  # TODO: fix spec
  # scenario 'when ajax modal is closed', js: true do

  #   within('.js-addedit-form-wrapper') do
  #     page.find('.js-fae-modal').click

  #     within('#fae-modal') do
  #       page.find('.simplemodal-close').click

  #       eventually {
  #         expect(page).to have_selector('.modal-callback--close')
  #         expect(page).to have_selector('.modal-callback--closed')
  #       }
  #     end
  #   end
  # end

end
