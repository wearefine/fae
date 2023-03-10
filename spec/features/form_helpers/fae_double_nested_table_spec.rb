require 'spec_helper'

feature 'fae_nested_table' do

  scenario 'should allow adding new items', js: true do
    release = FactoryBot.create(:release)
    aroma   = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    click_link aroma.name
    expect(page).to have_content('Add Sub Aroma')

    click_link 'Add Sub Aroma'
    expect(page).to have_css('form#new_sub_aroma')

    within(:css, 'form#new_sub_aroma') do
      fill_in 'Name', with: 'My Brand New Sub Smell!'
      click_button('Create Sub aroma')
    end

    eventually {
      # form should add item and only one item
      expect(page.find('#sub_aromas table')).to have_content('My Brand New Sub Smell!')
      expect(SubAroma.all.count).to eq(1)
    }
  end

  scenario 'should allow editing existing item', js: true do
    release   = FactoryBot.create(:release)
    aroma     = FactoryBot.create(:aroma, name: 'Roses', release: release)
    sub_aroma = FactoryBot.create(:sub_aroma, name: 'Sub Rose', aroma: aroma)

    admin_login
    visit edit_admin_release_path(release)

    click_link aroma.name
    expect(page.find('#sub_aromas table')).to have_content('Sub Rose')

    click_link sub_aroma.name
    expect(page).to have_css("form#edit_sub_aroma_#{sub_aroma.id}")

    within(:css, "form#edit_sub_aroma_#{sub_aroma.id}") do
      fill_in 'Name', with: 'Lavender'
      click_button('Update Sub aroma')
    end

    eventually {
      expect(page.find('#sub_aromas table')).to have_content('Lavender')
      expect(page.find('#sub_aromas table')).to_not have_content('Sub Rose')
    }
  end

  scenario 'should allow deletion of item', js: true do
    release   = FactoryBot.create(:release)
    aroma     = FactoryBot.create(:aroma, name: 'Roses', release: release)
    sub_aroma = FactoryBot.create(:sub_aroma, name: 'Sub Rose', aroma: aroma)

    admin_login
    visit edit_admin_release_path(release)

    click_link aroma.name

    page.find("tr#sub_aromas_#{sub_aroma.id} .js-delete-link").click

    eventually {
      expect(page.find('#sub_aromas table')).to_not have_content('Sub Rose')
    }
  end

  scenario 'should prevent parent form saving when user hits cancel on nested form unsaved changes alert', js: true do
    release   = FactoryBot.create(:release)
    aroma     = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    click_link aroma.name

    click_link 'Add Sub Aroma'
    expect(page).to have_css('form#new_sub_aroma')

    within(:css, 'form#new_sub_aroma') do
      fill_in 'Name', with: "Sub Aroma"
    end

    click_button 'Save'
    page.driver.browser.reject_js_confirms

    expect(page).to have_css('form#new_sub_aroma')
  end

  scenario 'allows parent form saving when user hits continue on nested form unsaved changes alert', js: true do
    release   = FactoryBot.create(:release)
    aroma     = FactoryBot.create(:aroma, name: 'Roses', release: release)

    admin_login
    visit edit_admin_release_path(release)

    click_link aroma.name

    click_link 'Add Sub Aroma'
    expect(page).to have_css('form#new_sub_aroma')

    within(:css, 'form#new_sub_aroma') do
      fill_in 'Name', with: "Sub Aroma"
    end

    click_button 'Save'
    page.driver.browser.accept_js_confirms

    eventually {
      expect(current_path).to eq(admin_releases_path)
    }
  end

end
