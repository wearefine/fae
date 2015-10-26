require 'spec_helper'

feature 'fae_nested_index_table' do

  scenario 'should allow adding new items', js: true do

    admin_login
    visit admin_cats_path

    click_link 'Add Cat'
    expect(page).to have_css('form#new_cat')

    within(:css, 'form#new_cat') do
      fill_in 'Name', with: 'Fuzzball'
      click_button('Create Cat')
    end
    expect(page.find('.cats .main_content-section-area table')).to have_content('Fuzzball')
  end

  scenario 'should allow editing existing item', js: true do
    cat = FactoryGirl.create(:cat, name: 'Buttercup')

    admin_login
    visit admin_cats_path

    expect(page.find('.cats .main_content-section-area table')).to have_content('Buttercup')

    click_link cat.name
    expect(page).to have_css("form#edit_cat_#{cat.id}")

    within(:css, "form#edit_cat_#{cat.id}") do
      fill_in 'Name', with: 'Pew Pew'
      click_button('Update Cat')
    end
    sleep 0.2
    expect(page.find('.cats .main_content-section-area table')).to have_content('Pew Pew')
    expect(page.find('.cats .main_content-section-area table')).to_not have_content('Buttercup')
  end

  scenario 'should allow deletion of item', js: true do
    cat = FactoryGirl.create(:cat, name: 'Snowball McPuffypants')

    admin_login
    visit admin_cats_path

    expect(page.find('.cats .main_content-section-area table')).to have_content('Snowball McPuffypants')

    # super hack due to webkit not able to click links without content
    # see: https://github.com/thoughtbot/capybara-webkit/issues/494
    evaluate_script "$('tr#cats_#{cat.id} .js-delete-link').click()"
    # should be more like...
    # page.find("tr#cats_#{cat.id} .js-delete-link").click

    expect(page.find('.cats .main_content-section-area table')).to_not have_content('Snowball McPuffypants')
  end

end
