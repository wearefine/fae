require 'spec_helper'

feature 'fae_nested_table' do

  scenario 'should titleize index header', js: true do
    admin_login
    visit admin_selling_points_path

    expect(page.find('.breadcrumbs li:last-child')).to have_content('Selling Points')
  end

  scenario 'should allow adding new items', js: true do
    release = FactoryBot.create(:release)

    admin_login
    visit edit_admin_release_path(release)

    click_link 'Add Aroma'
    expect(page).to have_css('form#new_aroma')

    within(:css, 'form#new_aroma') do
      fill_in 'Name', with: 'My Brand New Smell!'
      click_button('Create Aroma')
    end

    # form should add item and only one item
    expect(page.find('#aromas table')).to have_content('My Brand New Smell!')
    expect(Aroma.all.count).to eq(1)
  end

  scenario 'should allow editing existing item', js: true do
    release = FactoryBot.create(:release)
    aroma   = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#aromas table')).to have_content('Roses')

    click_link aroma.name
    expect(page).to have_css("form#edit_aroma_#{aroma.id}")

    within(:css, "form#edit_aroma_#{aroma.id}") do
      fill_in 'Name', with: 'Lavender'
      click_button('Update Aroma')
    end
    expect(page.find('#aromas table')).to have_content('Lavender')
    expect(page.find('#aromas table')).to_not have_content('Roses')
  end

  scenario 'should allow deletion of item', js: true do
    release = FactoryBot.create(:release)
    aroma   = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#aromas table')).to have_content('Roses')

    page.find("tr#aromas_#{aroma.id} .js-delete-link").click

    expect(page.find('#aromas table')).to_not have_content('Roses')
  end

  scenario 'should allow reordering of items', js: true do
    wine = FactoryBot.create(:wine)
    FactoryBot.create(:winemaker, name: 'Last', wine: wine, region_type: 1)
    FactoryBot.create(:winemaker, name: 'Middle', wine: wine, region_type: 1)
    FactoryBot.create(:winemaker, name: 'First', wine: wine, region_type: 1)

    admin_login
    visit edit_admin_wine_path(wine)

    expect(page.body).to match(/First.*Middle.*Last/)

    # within(:css, '#oregon_winemakers_section') do
    #   handle = all('tbody tr').last.find('.sortable-handle')
    #   handle.drag_to(find('thead'))
    # end
    #
    # TODO - drag_to is triggering the SetupController, which is in turn raising a no roles found
    # Not sure why, think it has something to do with Capybara's synchronize method
    # Proper code is above; hack below
    evaluate_script "$('#oregon_winemakers_section tbody').prepend( $('#oregon_winemakers_section tbody tr:last-child') ); $('#oregon_winemakers_section .sortable-handle:first-child').trigger('mousedown');"

    expect(page.body).to match(/Last.*First.*Middle/)
  end

  scenario 'should allow adding new items w params', js: true do
    wine = FactoryBot.create(:wine)

    admin_login
    visit edit_admin_wine_path(wine)

    click_link 'Add Oregon Winemaker'
    expect(page).to have_css('form#new_winemaker')

    within(:css, 'form#new_winemaker') do
      fill_in 'Name', with: 'Portland Joe'
      click_button('Create Winemaker')
    end

    expect(page.find('#oregon_winemakers_section table')).to have_content('Portland Joe')
    expect(page.find('#california_winemakers_section table')).to have_no_content('Portland Joe')
  end

end
