require 'spec_helper'

feature 'pagination' do
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
end
