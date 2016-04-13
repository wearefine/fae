require 'spec_helper'

feature 'Main Navigation' do

  scenario 'should highlight first and second level in header', js: true do
    admin_login
    visit admin_releases_path

    within('.main-header-nav > .-parent-current') do
      expect(page).to have_content('Products')
      page.find('a').hover
      expect(page.find('.-current')).to have_content('Releases')
    end
  end

  scenario 'should highlight third level in sidebar', js: true do
    admin_login
    visit admin_varietals_path

    within('.main-header-nav > .-parent-current') do
      expect(page).to have_content('Products')
      page.find('a').hover
      expect(page.find('.-current')).to have_content('Attributes')
    end

    expect(page.find('#js-sidenav .-current')).to have_content('Varietals')
  end

  scenario 'should highlight fourth level in sidebar', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    visit admin_team_coaches_path(team)

    within('.main-header-nav > .-parent-current') do
      expect(page).to have_content('Other Stuff')
      page.find('a').hover
      expect(page.find('.-current')).to have_content('Teams')
    end

    expect(page.find('#js-sidenav > ul > .-parent-current')).to have_content( team.name )
    expect(page.find('#js-sidenav .-current')).to have_content('Coaches')
  end

  scenario 'should not exist on a new page', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    visit new_admin_team_coach_path(team)

    expect(page).to_not have_selector('#js-sidenav')
  end

  scenario 'should not exist on an edit page', js: true do
    admin_login
    coach = FactoryGirl.create(:coach)
    visit edit_admin_team_coach_path(coach.team, coach)

    expect(page).to_not have_selector('#js-sidenav')
  end

  scenario 'accordions should expand and collapse siblings when they are clicked', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    team2 = FactoryGirl.create(:team)
    visit admin_team_coaches_path(team)

    # Ensure only one accordion is open on load
    expect(page).to_not have_selector('#js-sidenav .js-accordion.-open > a', text: team2.name)
    expect(page).to have_selector('#js-sidenav .js-accordion.-parent-current > a', text: team.name)

    page.find('#js-sidenav .js-accordion > a', text: team2.name).click

    # Ensure only one accordion is open after click
    expect(page).to have_selector('#js-sidenav .js-accordion.-open > a', text: team2.name)
    expect(page).to_not have_selector('#js-sidenav .js-accordion.-open > a', text: team.name)
  end

end
