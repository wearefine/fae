require 'spec_helper'

feature 'filtering' do
  scenario 'pagination', js: true do
    (1..6).each do |n|
      FactoryGirl.create(:team, name: "team #{n}")
    end

    admin_login
    visit admin_teams_path
    expect(page).to have_css("table tr", count: 6)
    visit admin_teams_path + '?page=2'
    expect(page).to have_css("table tr", count: 2)
  end

  scenario 'filtering', js: true do
    red = FactoryGirl.create(:wine, name_en: 'Red')
    white = FactoryGirl.create(:wine, name_en: 'White')
    FactoryGirl.create(:release, name: 'Release 1', wine: red)
    FactoryGirl.create(:release, name: 'Release 2', wine: red)
    FactoryGirl.create(:release, name: 'Release 3', wine: white)

    admin_login

    visit admin_releases_path + "#?wine=#{red.id}"
    sleep 5.seconds
    expect(page).to have_content 'Release 1'
    expect(page).to have_content 'Release 2'
    expect(page).to_not have_content 'Release 3'

    visit admin_releases_path + "#?wine=#{white.id}"
    expect(page).to have_content 'Release 3'
    expect(page).to_not have_content 'Release 1'
    expect(page).to_not have_content 'Release 2'
  end

  scenario 'activity log date filtering', js: true do
    red = FactoryGirl.create(:wine, name_en: 'Red')
    white = FactoryGirl.create(:wine, name_en: 'White')
    release_1 = FactoryGirl.create(:release, name: 'Release 1', wine: red)
    release_2 = FactoryGirl.create(:release, name: 'Release 2', wine: red)
    release_3 = FactoryGirl.create(:release, name: 'Release 3', wine: white)

    # force some changes to be a month ago
    now = Date.today
    Fae::Change.find_by_changeable_id_and_changeable_type(release_1.id, 'Release').update_columns(updated_at: (now - 1.month))
    Fae::Change.find_by_changeable_id_and_changeable_type(release_2.id, 'Release').update_columns(updated_at: (now - 1.month))

    admin_login
    visit "#{fae.activity_log_path}#?start_date=#{URI.escape((now - 2.weeks).to_s)}"
    sleep 5.seconds

    expect(page).to_not have_content 'Release 1'
    expect(page).to_not have_content 'Release 2'
    expect(page).to have_content 'Release 3'

    visit "#{fae.activity_log_path}#?end_date=#{URI.escape((now - 2.weeks).to_s)}"
    expect(page).to have_content 'Release 1'
    expect(page).to have_content 'Release 2'
    expect(page).to_not have_content 'Release 3'

    visit "#{fae.activity_log_path}#?start_date=#{URI.escape((now - 5.weeks).to_s)}&end_date=#{URI.escape((now - 2.weeks).to_s)}"
    expect(page).to have_content 'Release 1'
    expect(page).to have_content 'Release 2'
    expect(page).to_not have_content 'Release 3'

  end
end
