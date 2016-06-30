require 'spec_helper'

feature 'validations' do

  scenario 'dates in mm/dd/yy format should sort in correct order', js: true do
    admin_login
    FactoryGirl.create(:release, name: 'Release 1')
    FactoryGirl.create(:release, name: 'Release 2', updated_at: 10.days.ago)
    FactoryGirl.create(:release, name: 'Release 3', updated_at: 1.day.ago)

    visit admin_legacy_releases_path

    expect(page.find('tbody').text).to match(/Release 1.*Release 2.*Release 3/)
    page.find('div', text: /\AModified\z/).click
    expect(page.find('tbody').text).to match(/Release 2.*Release 3.*Release 1/)
  end

end
