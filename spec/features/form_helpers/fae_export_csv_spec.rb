require 'spec_helper'

feature 'fae_export_csv' do

  scenario 'if items not present export to csv button should not be present', js: true do
    admin_login
    visit admin_releases_path

    expect(page).to_not have_css('a.csv-button')
    expect(page).to_not have_content("Export to CSV")
  end


  scenario 'if items present export to csv button should be present', js: true do
    release1 = FactoryGirl.create(:release, name: "Unique Release", id: 1, release_date: Date.today, intro: "This is the introduction")
    admin_login
    visit admin_releases_path

    expect(page).to have_css('a.csv-button')
    expect(page).to have_content("Export to CSV")
    page.find('.csv-button').click
    expect(page).to have_content('This is the introduction')
  end

end
