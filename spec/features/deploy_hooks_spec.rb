require 'spec_helper'

feature 'Deploy Hooks' do

  before(:each) do
    super_admin_login
    visit fae.option_path
  end

  scenario 'can manage deploy hooks', js: true do
    expect(page).to have_content('DEPLOY HOOKS')
    click_link('Add Deploy Hook')
    eventually {
      expect(page).to have_content('New Deploy Hook')
      fill_in('deploy_hook_environment', with: 'Test')
      fill_in('deploy_hook_url', with: 'test.com')
      click_button('Create Deploy hook')
      eventually {
        within('#deploy_hooks') do
          expect(page).to have_content('Test')
          expect(page).to have_content('test.com')
        end
      }
    }
  end

end
