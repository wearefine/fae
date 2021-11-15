require 'spec_helper'

feature 'Publish' do

  before(:each) do
    super_admin_login
    visit fae.publish_path
  end

  scenario 'shows completed deploys', js: true do
    expect(page).to have_content('Staging complete')
  end

  scenario 'does not show incomplete deploys', js: true do
    expect(page).to_not have_content('Staging processing')
    expect(page).to_not have_content('Staging building')
  end

  scenario 'shows error content', js: true do
    expect(page).to have_content('Error!')
  end

end
