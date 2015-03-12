require 'spec_helper'

feature 'fae_pulldown' do

  scenario 'should open and select items', js: true do
    varietal = FactoryGirl.create(:varietal)

    admin_login
    visit new_admin_release_path

    page.find('#release_varietal_id_chosen').click
    page.find('#release_varietal_id_chosen .active-result', text: varietal.name).click

    expect(page.find('#release_varietal_id_chosen .chosen-single')).to have_content(varietal.name)
  end

  scenario 'should not display search if pull down has less than 10 items', js: true do
    FactoryGirl.create_list(:varietal, 9)

    admin_login
    visit new_admin_release_path

    expect(page).to have_css('#release_varietal_id_chosen.chosen-container-single-nosearch')
  end

  scenario 'should display search if pull down has 10 or more items', js: true do
    FactoryGirl.create_list(:varietal, 10)

    admin_login
    visit new_admin_release_path

    expect(page).to_not have_css('#release_varietal_id_chosen.chosen-container-single-nosearch')
  end

  scenario 'should order by defined collection' do
    FactoryGirl.create_list(:wine, 3)

    admin_login
    visit new_admin_release_path

    wines = page.all(:css, '#release_wine_id option')
    expect( wines.last ).to have_content('Wine Name 3')
  end

end
