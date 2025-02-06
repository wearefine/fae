require 'spec_helper'

feature 'Cta' do

  before(:each) do
    admin_login
    @beer = FactoryBot.create(:beer, name: 'Mmmm Beer')
  end

  scenario 'form shows cta inputs', js: true do
    visit edit_admin_beer_path(@beer.id)
    expect(page).to have_content('Test CTA Label')
    expect(page).to have_content('Test CTA Link')
    expect(page).to have_content('Test CTA Alt Text')
  end

  scenario 'cta fields are editable/saveable', js: true do
    visit edit_admin_beer_path(@beer.id)
    fill_in('Test CTA Label', with: 'cta label content')
    fill_in('Test CTA Link', with: 'cta link content')
    fill_in('Test CTA Alt Text', with: 'cta alt text content')

    find('input[name="commit"]').click

    eventually {
      expect(page).to have_content('Add Beer')
    }

    visit edit_admin_beer_path(@beer.id)
    expect(page).to have_field('Name', with: 'Mmmm Beer')
    expect(page).to have_field('Test CTA Label', with: 'cta label content')
    expect(page).to have_field('Test CTA Link', with: 'cta link content')
    expect(page).to have_field('Test CTA Alt Text', with: 'cta alt text content')

  end

end
