require 'spec_helper'

feature 'Sites Deploy' do

  before(:each) do
    admin_login
    @site = FactoryBot.create(:fae_site, name: 'Test Site')
    FactoryBot.create(:fae_site_deploy_hook, environment: 'Production', site: @site)
    FactoryBot.create(:fae_site_deploy_hook, environment: 'Staging', site: @site)
    FactoryBot.create(:fae_site_deploy_hook, environment: 'Development', site: @site)
  end

  scenario 'draws nav dropdown, adjusts deploys page for passed site', js: true do
    visit fae.sites_path
    within('.utility-nav') do
      find('a', text: 'Deploy').hover
      expect(page).to have_link('Test Site')
      click_link('Test Site')
    end
    eventually {
      expect(page).to have_content('Deploy - Test Site')
      expect(find('main.content')['data-fae-site-id'].to_i).to eq(@site.id)
    }
  end

  scenario 'draws buttons', js: true do
    visit fae.deploy_path(site_id: @site.id)
    expect(page).to have_button('Deploy Production', disabled: true)
    expect(page).to have_button('Deploy Staging', disabled: true)
    expect(page).to have_button('Deploy Development', disabled: true)
  end

  scenario 'draws deploying table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('DEPLOYING')
    expect(page).to have_content('Staging building')
    expect(page).to have_content('10/22/2021 2:57 pm')
    expect(page).to have_content('00:01:33')
  end

  scenario 'draws past deploys table', js: true do
    visit fae.deploy_path
    expect(page).to have_content('PAST DEPLOYS')
    expect(page).to have_content('FINE dev update')
    expect(page).to have_content('FINE admin triggered a Staging build')
    expect(page).to have_content('An error occurred. Please contact your FINE team.')
  end
  
end
