require 'spec_helper'

feature 'Fae Sites' do

  before(:each) do
    super_admin_login
    visit fae.sites_path
  end

  scenario 'can manage sites and their deploy hooks', js: true do
    expect(page).to have_content('Add Site')
    click_link('Add Site')
    eventually {
      expect(page).to have_content('New Site')
      fill_in('site_name', with: 'Test Site')
      fill_in('site_netlify_site', with: 'testsite')
      fill_in('site_netlify_site_id', with: 'abc123')
      click_button('Save')
      eventually {
        within('table') do
          expect(page).to have_content('Test Site')
        end
        click_link('Test Site')
        eventually {
          expect(page).to have_content('Add Site Deploy Hook')
          click_link('Add Site Deploy Hook')
          eventually {
            fill_in('site_deploy_hook_environment', with: 'Test Environment')
            fill_in('site_deploy_hook_url', with: 'https://test.com')
            click_button('Create Site deploy hook')
            eventually {
              within('table') do
                expect(page).to have_content('Test Environment')
              end
            }
          }
        }
      }
    }
  end

end
