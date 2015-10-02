require 'spec_helper'

feature 'validations' do

  scenario 'dates in mm/dd/yy format should sort in correct order', js: true do
    admin_login
    release_1 = FactoryGirl.create(:release)
    release_2 = FactoryGirl.create(:release, updated_at: 10.days.ago)
    release_3 = FactoryGirl.create(:release, updated_at: 1.day.ago)
    @items = Release.for_fae_index
    visit admin_releases_path
    page.find('.sorter-mmddyy').click

    expect(@items).to eq([release_2, release_3, release_1])
  end

end
