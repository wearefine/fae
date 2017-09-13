require 'spec_helper'

feature 'filtering' do
  scenario 'pagination', js: true do
    (1..6).each do |n|
      FactoryGirl.create(:team, name: "team #{n}")
    end

    admin_login
    visit admin_teams_path

    expect(page).to have_css("table.paginated tr", count: 6)
    visit admin_teams_path + '?page=2'
    expect(page).to have_css("table.paginated tr", count: 2)
  end

  scenario 'filtering', js: true do
    red = FactoryGirl.create(:wine, name_en: 'Red')
    white = FactoryGirl.create(:wine, name_en: 'White')
    FactoryGirl.create(:release, name: 'Release 1', wine: red)
    FactoryGirl.create(:release, name: 'Release 2', wine: red)
    FactoryGirl.create(:release, name: 'Release 3', wine: white)

    admin_login
    visit admin_releases_path + "#?wine=#{red.id}"
    expect(page).to have_content 'Release 1'
    expect(page).to have_content 'Release 2'
    expect(page).to_not have_content 'Release 3'

    visit admin_releases_path + "#?wine=#{white.id}"
    expect(page).to have_content 'Release 3'
    expect(page).to_not have_content 'Release 1'
    expect(page).to_not have_content 'Release 2'
  end
end
