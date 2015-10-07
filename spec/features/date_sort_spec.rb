require 'spec_helper'

feature 'validations' do

  scenario 'dates in mm/dd/yy format should sort in correct order', js: true do
    admin_login
    release_1 = FactoryGirl.create(:release)
    release_2 = FactoryGirl.create(:release, updated_at: 10.days.ago)
    release_3 = FactoryGirl.create(:release, updated_at: 1.day.ago)

    visit admin_releases_path
    page.find('div', text: /\AModified\z/).click

    expect(page.find('tbody tr:nth-child(1)')).to have_content(release_2.name + ' ' + release_2.wine.name_en + ' ' + release_2.updated_at.strftime('%m/%d/%y') + ' Yes No Yes No')
    expect(page.find('tbody tr:nth-child(2)')).to have_content(release_3.name + ' ' + release_3.wine.name_en + ' ' + release_3.updated_at.strftime('%m/%d/%y') + ' Yes No Yes No')
    expect(page.find('tbody tr:nth-child(3)')).to have_content(release_1.name + ' ' + release_1.wine.name_en + ' ' + release_1.updated_at.strftime('%m/%d/%y') + ' Yes No Yes No')
  end

end
