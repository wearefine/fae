require 'spec_helper'

feature 'Main Navigation' do

  scenario 'should highlight first level index', js: true do
    admin_login
    visit admin_releases_path

    expect(page.find('a.current').text).to eq('Current')
  end

  scenario 'should highlight first level new page', js: true do
    admin_login
    visit new_admin_release_path

    expect(page.find('a.current').text).to eq('Current')
  end

  scenario 'should highlight first level edit page', js: true do
    admin_login
    release = FactoryGirl.create(:release)
    visit edit_admin_release_path(release)

    expect(page.find('a.current').text).to eq('Current')
  end

  scenario 'should highlight second level index', js: true do
    super_admin_login
    visit fae.users_path

    expect(page.find('a.current').text).to eq('Users')
  end

  scenario 'should highlight second level new page', js: true do
    super_admin_login
    visit fae.new_user_path

    expect(page.find('a.current').text).to eq('Users')
  end

  scenario 'should highlight second level edit page', js: true do
    super_admin_login
    user = FactoryGirl.create(:fae_user)
    visit fae.edit_user_path(user)

    expect(page.find('a.current').text).to eq('Users')
  end

  scenario 'should highlight third level index', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    visit admin_team_coaches_path(team)

    expect(page.find('a.current').text).to eq('Coaches')
  end

  scenario 'should highlight third level new page', js: true do
    admin_login
    team = FactoryGirl.create(:team)
    visit new_admin_team_coach_path(team)

    expect(page.find('a.current').text).to eq('Coaches')
  end

  scenario 'should highlight third level edit page', js: true do
    admin_login
    coach = FactoryGirl.create(:coach)
    visit edit_admin_team_coach_path(coach.team, coach)

    expect(page.find('a.current').text).to eq('Coaches')
  end

  scenario 'should expand first level accordion', js: true do
    admin_login
    visit admin_releases_path

    expect(page).to_not have_selector('.main_nav a', text: 'Except Open To Another Drawer')

    page.find('.main_nav-accordion a', text: 'Look This Drawer Does Nothing').click

    # Link is now visible
    expect(page).to have_selector('.main_nav a', text: 'Except Open To Another Drawer')
  end

  scenario 'should expand second level accordion', js: true do
    admin_login
    visit admin_releases_path

    page.find('.main_nav a', text: 'Look This Drawer Does Nothing').click
    page.find('.main_nav a', text: 'Except Open To Another Drawer').click

    expect(page).to have_selector('.main_nav a', text: 'To A Link That Goes Nowhere')
  end

end
