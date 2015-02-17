require 'spec_helper'

feature 'fae_prefix' do

  scenario 'should have prefix and placeholder' do
    admin_login
    visit new_admin_release_path

    within('div.release_price .input-symbol--prefix') do
      expect(page).to have_content('$')
    end
  end

end