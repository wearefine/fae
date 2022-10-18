require 'spec_helper'

feature 'Rebinding Markdown' do

  scenario 'should only bind new markdown elements when nested add is clicked', js: true do
    release = FactoryBot.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
    admin_login
    visit edit_admin_release_path(release)
    click_link 'Add Aroma'
    click_link 'Add Aroma'

    expect(page).to have_selector('.CodeMirror', count: 2)
  end

end