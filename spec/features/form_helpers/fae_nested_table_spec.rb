require 'spec_helper'

feature 'fae_nested_table' do

  scenario 'should titleize index header', js: true do
    admin_login
    visit admin_selling_points_path

    expect(page.find('.main_content-header-wrapper h1')).to have_content('Selling Points')
  end

  scenario 'should allow adding new items', js: true do
    release = FactoryGirl.create(:release)

    admin_login
    visit edit_admin_release_path(release)

    click_link 'Add Aroma'
    expect(page).to have_css('form#new_aroma')

    within(:css, 'form#new_aroma') do
      fill_in 'Name', with: 'My Brand New Smell!'
      click_button('Create Aroma')
    end
    expect(page.find('#aromas_section table')).to have_content('My Brand New Smell!')
  end

  scenario 'should allow editing existing item', js: true do
    release = FactoryGirl.create(:release)
    aroma   = FactoryGirl.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#aromas_section table')).to have_content('Roses')

    click_link aroma.name
    expect(page).to have_css("form#edit_aroma_#{aroma.id}")

    within(:css, "form#edit_aroma_#{aroma.id}") do
      fill_in 'Name', with: 'Lavender'
      click_button('Update Aroma')
    end
    expect(page.find('#aromas_section table')).to have_content('Lavender')
    expect(page.find('#aromas_section table')).to_not have_content('Roses')
  end

  scenario 'should allow deletion of item', js: true do
    release = FactoryGirl.create(:release)
    aroma   = FactoryGirl.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#aromas_section table')).to have_content('Roses')

    # super hack due to webkit not able to click links without content
    # see: https://github.com/thoughtbot/capybara-webkit/issues/494
    evaluate_script "$('tr#aromas_#{aroma.id} .js-delete-link').click()"
    # should be more like...
    # page.find("tr#aromas_#{aroma.id} .js-delete-link").click

    expect(page.find('#aromas_section table')).to_not have_content('Roses')
  end

  scenario 'should allow reordering of items', js: true do
    wine = FactoryGirl.create(:wine)
    FactoryGirl.create(:winemaker, name: 'Last', wine: wine)
    FactoryGirl.create(:winemaker, name: 'Middle', wine: wine)
    FactoryGirl.create(:winemaker, name: 'First', wine: wine)

    admin_login
    visit edit_admin_wine_path(wine)

    expect(page.body).to match(/First.*Middle.*Last/)

    within(:css, '#winemakers_section') do
      handle = all('tbody tr').last.find('.sortable-handle')
      handle.drag_to(find('thead'))
    end

    expect(page.body).to match(/Last.*First.*Middle/)
  end

end
