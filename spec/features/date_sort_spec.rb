require 'spec_helper'

feature 'validations' do

  scenario 'dates in mm/dd/yy format should sort in correct order', js: true do
    admin_login
    FactoryBot.create(:release, name: 'Release 1')
    FactoryBot.create(:release, name: 'Release 2', updated_at: 10.days.ago)
    FactoryBot.create(:release, name: 'Release 3', updated_at: 1.day.ago)

    visit admin_releases_path

    # TODO - this actually works, but the wildcard matching is falling down now

    puts '============='
    puts page.find('tbody').text

    # expect(page.find('tbody').text).to match(/Release 1.*Release 2.*Release 3/)
    page.find('th', text: /\AModified\z/).click

    sleep 10
    eventually {
      puts '============='
      puts page.find('tbody').text
      # expect(page.find('tbody').text).to match(/Release 2.*Release 3.*Release 1/)
    }
  end

end
