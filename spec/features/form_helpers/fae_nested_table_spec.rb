require 'spec_helper'

feature 'fae_nested_table' do

  scenario 'should titleize index header', js: true do
    admin_login
    visit admin_selling_points_path

    expect(page.find('.breadcrumbs li:last-child')).to have_content('Selling Points')
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
    expect(page.find('#nested_table table')).to have_content('My Brand New Smell!')
  end

  scenario 'should allow editing existing item', js: true do
    release = FactoryGirl.create(:release)
    aroma   = FactoryGirl.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#nested_table table')).to have_content('Roses')

    click_link aroma.name
    expect(page).to have_css("form#edit_aroma_#{aroma.id}")

    within(:css, "form#edit_aroma_#{aroma.id}") do
      fill_in 'Name', with: 'Lavender'
      click_button('Update Aroma')
    end
    expect(page.find('#nested_table table')).to have_content('Lavender')
    expect(page.find('#nested_table table')).to_not have_content('Roses')
  end

  scenario 'should allow deletion of item', js: true do
    release = FactoryGirl.create(:release)
    aroma   = FactoryGirl.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#nested_table table')).to have_content('Roses')

    page.find("tr#aromas_#{aroma.id} .js-delete-link").click

    expect(page.find('#nested_table table')).to_not have_content('Roses')
  end

  scenario 'should allow reordering of items', js: true do
    wine = FactoryGirl.create(:wine)
    FactoryGirl.create(:winemaker, name: 'Last', wine: wine, region_type: 1)
    FactoryGirl.create(:winemaker, name: 'Middle', wine: wine, region_type: 1)
    FactoryGirl.create(:winemaker, name: 'First', wine: wine, region_type: 1)

    admin_login
    visit edit_admin_wine_path(wine)

    expect(page.body).to match(/First.*Middle.*Last/)

    # handle = page.find('#oregon_winemakers_section tbody tr:last-child .sortable-handle')
    # target = page.find('#oregon_winemakers_section thead')
    # handle.drag_to(target)
    #
    # TODO - drag_to is triggering the SetupController, which is in turn raising a no roles found
    # Not sure why, think it has something to do with Capybara's synchronize method
    # Proper code is above; hack below
    evaluate_script "$('#oregon_winemakers_section tbody').prepend( $('#oregon_winemakers_section tbody tr:last-child') ); $('#oregon_winemakers_section .js-sort-row').trigger('sortupdate');"

    expect(page.body).to match(/Last.*First.*Middle/)
  end

  scenario 'should allow adding new items w params', js: true do
    wine = FactoryGirl.create(:wine)

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
