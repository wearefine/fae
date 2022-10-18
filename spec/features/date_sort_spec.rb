require 'spec_helper'

feature 'validations' do

  scenario 'dates in mm/dd/yy format should sort in correct order', js: true do
    admin_login
    FactoryBot.create(:release, name: 'Release 1')
    FactoryBot.create(:release, name: 'Release 2', updated_at: 10.days.ago)
    FactoryBot.create(:release, name: 'Release 3', updated_at: 1.day.ago)

    visit admin_releases_path

    expect(page.find('tbody').text.gsub("\n","")).to match(/Release 1.*Release 2.*Release 3/)
    page.find('th', text: /\AModified\z/).click

    eventually {
      expect(page.find('tbody').text.gsub("\n","")).to match(/Release 2.*Release 3.*Release 1/)
    }
  end

end
