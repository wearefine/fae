require 'spec_helper'

feature 'Seo Set' do

  before(:each) do
    admin_login
    @beer = FactoryBot.create(:beer, name: 'Mmmm Beer')
  end

  scenario 'form shows seo set inputs', js: true do
    visit edit_admin_beer_path(@beer.id)
    expect(page).to have_content('SEO Title')
    expect(page).to have_content('SEO Description')
    expect(page).to have_content('Social Media Title')
    expect(page).to have_content('Social Media Description')
    expect(page).to have_content('Social Media Image')
  end

  scenario 'seo fields are editable/saveable', js: true do
    visit edit_admin_beer_path(@beer.id)
    fill_in('SEO Title', with: 'seo title content')
    fill_in('SEO Description', with: 'seo description content')
    fill_in('Social Media Title', with: 'social media title content')
    fill_in('Social Media Description', with: 'social media description content')

    find('input[name="commit"]').click

    eventually {
      expect(page).to have_content('Add Beer')
    }

    visit edit_admin_beer_path(@beer.id)
    expect(page).to have_field('Name', with: 'Mmmm Beer')
    expect(page).to have_field('SEO Title', with: 'seo title content')
    expect(page).to have_field('SEO Description', with: 'seo description content')
    expect(page).to have_field('Social Media Title', with: 'social media title content')
    expect(page).to have_field('Social Media Description', with: 'social media description content')

  end

end
