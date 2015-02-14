require 'spec_helper'

feature 'fae_suffix' do

  scenario 'should have suffix' do
    admin_login
    visit new_admin_release_path

    within('div.release_weight .input-symbol--suffix') do
      expect(page).to have_content('lbs')
    end
  end

end
