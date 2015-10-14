require 'spec_helper'

feature 'Clone record' do

  context 'when there are no special relationships' do
    scenario 'should copy the record and belongs_to association', js: true do
      release = FactoryGirl.create(:release, name: 'Ima Release')
      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      expect(find_field('Name').value).to eq('Ima Release-2')
    end
  end

  context 'when there are relationship' do
    scenario 'should copy the record and belongs_to association and has_many assocations', js: true do
      release = FactoryGirl.create(:release, name: 'Ima Release')
      event_1 = FactoryGirl.create(:event)
      event_2 = FactoryGirl.create(:event)
      release.events << event_1
      release.events << event_2
      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      expect(find_field('Name').value).to eq('Ima Release-2')
      expect(page.find('.release_events')).to have_content(event_1.name)
      expect(page.find('.release_events')).to have_content(event_2.name)
    end
  end

end
