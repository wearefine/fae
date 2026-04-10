require 'spec_helper'

feature 'Preview Links' do
  before :each do
    admin_login
  end

  scenario 'displays stage and prod preview links when URLs are configured', js: true do
    # Set up stage and prod URLs
    options = Fae::Option.instance
    options.stage_url = 'https://stage.example.com'
    options.live_url = 'https://www.example.com'
    options.save

    # Create a wine - Wine#detail_path returns "/wines/#{id}"
    wine = FactoryBot.create(:wine, name_en: 'Test Wine')

    visit edit_admin_wine_path(wine)

    expect(page).to have_link('Stage', href: "https://stage.example.com/wines/#{wine.id}")
    expect(page).to have_link('Prod', href: "https://www.example.com/wines/#{wine.id}")
  end

  scenario 'handles trailing slashes on URLs correctly', js: true do
    # Set up URLs with trailing slashes
    options = Fae::Option.instance
    options.stage_url = 'https://stage.example.com/'
    options.live_url = 'https://www.example.com/'
    options.save

    wine = FactoryBot.create(:wine, name_en: 'Test Wine')

    visit edit_admin_wine_path(wine)

    # Should not have double slashes
    expect(page).to have_link('Stage', href: "https://stage.example.com/wines/#{wine.id}")
    expect(page).to have_link('View on prod', href: "https://www.example.com/wines/#{wine.id}")
  end

  scenario 'displays only prod link when stage URL is not configured', js: true do
    options = Fae::Option.instance
    options.stage_url = nil
    options.live_url = 'https://www.example.com'
    options.save

    wine = FactoryBot.create(:wine, name_en: 'Test Wine')

    visit edit_admin_wine_path(wine)

    expect(page).to_not have_link('Stage')
    expect(page).to have_link('Prod', href: "https://www.example.com/wines/#{wine.id}")
  end

  scenario 'does not display preview links when item has no detail_path method', js: true do
    options = Fae::Option.instance
    options.stage_url = 'https://stage.example.com'
    options.live_url = 'https://www.example.com'
    options.save

    # Beer model does not have a detail_path method
    beer = FactoryBot.create(:beer, name: 'Test Beer')

    visit edit_admin_beer_path(beer)

    expect(page).to_not have_css('.preview-links')
  end
end
