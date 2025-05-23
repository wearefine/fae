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

    eventually {
      # form should add item and only one item
      expect(page.find('#aromas table')).to have_content('My Brand New Smell!')
      expect(Aroma.all.count).to eq(1)
    }
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

    eventually {
      expect(page.find('#aromas table')).to have_content('Lavender')
      expect(page.find('#aromas table')).to_not have_content('Roses')
    }
  end

  scenario 'should allow deletion of item', js: true do
    release = FactoryBot.create(:release)
    aroma   = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    expect(page.find('#aromas table')).to have_content('Roses')

    page.find("tr#aromas_#{aroma.id} .js-delete-link").click

    eventually {
      expect(page.find('#aromas table')).to_not have_content('Roses')
    }
  end

  scenario 'should allow reordering of items', js: true do
    wine = FactoryBot.create(:wine)
    winemaker_1 = FactoryBot.create(:winemaker, name: 'Last', wine: wine, region_type: 1)
    winemaker_2 = FactoryBot.create(:winemaker, name: 'Middle', wine: wine, region_type: 1)
    winemaker_3 = FactoryBot.create(:winemaker, name: 'First', wine: wine, region_type: 1)

    admin_login
    visit edit_admin_wine_path(wine)

    expect(Winemaker.order(:position)).to eq([winemaker_3, winemaker_2, winemaker_1])

    handle = find("#winemakers_#{winemaker_1.id} .sortable-handle i")
    target = find("#winemakers_#{winemaker_3.id} .sortable-handle i")
    handle.drag_to(target)

    eventually {
      expect(Winemaker.order(:position)).to eq([winemaker_3, winemaker_1, winemaker_2])
    }
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

    eventually {
      expect(page.find('#oregon_winemakers_section table')).to have_content('Portland Joe')
      expect(page.find('#california_winemakers_section table')).to have_no_content('Portland Joe')
    }
  end

  scenario 'should prevent parent form saving when user hits cancel on nested form unsaved changes alert', js: true do
    release = FactoryBot.create(:release)

    admin_login
    visit edit_admin_release_path(release)

    click_link 'Add Release Note'
    expect(page).to have_css('form#new_release_note')


    within(:css, 'form#new_release_note') do
      fill_in 'Title', with: "I'm a release note"
    end

    click_button 'Save'
    page.driver.browser.reject_js_confirms
    
    expect(page).to have_css('form#new_release_note')
  end

  scenario 'allows parent form saving when user hits continue on nested form unsaved changes alert', js: true do
    release = FactoryBot.create(:release)

    admin_login
    visit edit_admin_release_path(release)

    click_link 'Add Release Note'
    expect(page).to have_css('form#new_release_note')

    within(:css, 'form#new_release_note') do
      fill_in 'Title', with: "I'm a release note"
    end

    click_button 'Save'
    page.driver.browser.accept_js_confirms

    eventually {
      expect(current_path).to eq(admin_releases_path)
    }
  end

end
