require 'spec_helper'

feature 'fae_nested_table_params' do

  scenario 'should allow adding new items with params', js: true do
    wine = FactoryGirl.create(:wine)

    admin_login
    visit edit_admin_wine_path(wine)

    click_link 'Add Winemaker'
    expect(page).to have_css('form#new_winemaker')

    within(:css, 'form#new_winemaker') do
      fill_in 'Name', with: 'My Brand New Smell!'
      click_button('Create Aroma')
    end
    expect(page.find('#aromas_section table')).to have_content('My Brand New Smell!')
  end


end
