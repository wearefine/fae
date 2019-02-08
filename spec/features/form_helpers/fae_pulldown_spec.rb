require 'spec_helper'

feature 'fae_pulldown' do

  scenario 'should open and select items', js: true do
    varietal = FactoryBot.create(:varietal)

    admin_login
    visit new_admin_release_path

    page.find('#release_varietal_id_chosen').click
    page.find('#release_varietal_id_chosen .active-result', text: varietal.name).click

    expect(page.find('#release_varietal_id_chosen .chosen-single')).to have_content(varietal.name)
  end

  scenario 'should not display search if pull down has less than 10 items', js: true do
    FactoryBot.create_list(:varietal, 9)

    admin_login
    visit new_admin_release_path

    expect(page).to have_css('#release_varietal_id_chosen.chosen-container-single-nosearch')
  end

  scenario 'should display search if pull down has 10 or more items', js: true do
    FactoryBot.create_list(:varietal, 10)

    admin_login
    visit new_admin_release_path

    expect(page).to_not have_css('#release_varietal_id_chosen.chosen-container-single-nosearch')
  end

  scenario 'should order by defined collection' do
    FactoryBot.create(:wine, name_en: 'Wine A')
    FactoryBot.create(:wine, name_en: 'Wine B')
    FactoryBot.create(:wine, name_en: 'Wine C')

    admin_login
    visit new_admin_release_path

    wines = page.all(:css, '#release_wine_id option')
    expect( wines.last ).to have_content('Wine C')
  end

  scenario 'should not have duplicate "Select One" option' do
    FactoryBot.create(:person, name: 'Mike')

    admin_login
    visit new_admin_location_path
    expect_correct_contact_options

    fill_in 'location_name', with: 'Mike'
    click_button('Save')

    visit edit_admin_location_path(Location.last)
    expect_correct_contact_options
  end

  def expect_correct_contact_options
    dropdown_options = all("option")
    expect(dropdown_options[0].text).to eq 'Select One'
    expect(dropdown_options[1].text).to eq 'Mike'
  end
end
