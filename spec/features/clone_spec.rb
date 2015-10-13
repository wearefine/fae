require 'spec_helper'

feature 'Clone record' do

  context 'when there are no special relationships' do
    scenario 'should copy the record and belongs_to association', js: true do
      release = FactoryGirl.create(:release, name: 'I am a Release')
      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      expect(find_field('Name').value).to eq('I am a Release-2')
    end
  end

end
