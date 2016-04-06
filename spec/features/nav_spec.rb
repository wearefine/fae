require 'spec_helper'

feature 'Main Navigation' do

  scenario 'should highlight all levels of navigation', js: true do
    admin_login
    visit admin_varietals_path

    # top nav (TODO)
    # expect(page.find('.main-header-nav .-parent-current a').text).to eq ('Products')
    # top nav dropdown
    expect(page.find('.main-header-nav a.-current', visible: false).text(:all)).to eq('Attributes')
    # sidenav first level
    expect(page.find('.sidenav a.-current').text).to eq ('Varietals')
    # sidenav second level (TODO)
  end

  scenario 'should not exist on a new page', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    visit new_admin_team_coach_path(team)

    expect(page).to_not have_selector('.sidenav')
  end

  scenario 'should not exist on an edit page', js: true do
    admin_login
    coach = FactoryGirl.create(:coach)
    visit edit_admin_team_coach_path(coach.team, coach)

    expect(page).to_not have_selector('.sidenav')
  end

end
