require 'spec_helper'

feature 'Deploy' do

  before(:each) do
    Fae.deploys_to = 'Cloudflare'
    admin_login
    FactoryBot.create(:fae_deploy_hook, environment: 'Production')
    FactoryBot.create(:fae_deploy_hook, environment: 'Staging')
    FactoryBot.create(:fae_deploy_hook, environment: 'Development')
  end

  # test drawing both tables

  scenario 'draws buttons', js: true do
    visit fae.deploy_path
    expect(page).to have_button('Deploy Production', disabled: true)
    expect(page).to have_button('Deploy Staging', disabled: true)
    expect(page).to have_button('Deploy Development', disabled: true)
  end

  scenario 'draws deploying table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('DEPLOYING')
    expect(page).to have_content('CMS Admin')
    expect(page).to have_content('01/09/2023')
    expect(page).to have_content('queued:active')
  end

  scenario 'draws past deploys table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('PAST DEPLOYS')
    expect(page).to have_content('FINE Dev Update')
    expect(page).to have_content('Cloudflare Admin')
    expect(page).to have_content('deploy:success')
  end

  scenario 'user is attached to a deploy', js: true do
    FactoryBot.create(:fae_deploy)
    visit fae.deploy_path
    expect(page).to have_content('Deploy Person')
  end

end
