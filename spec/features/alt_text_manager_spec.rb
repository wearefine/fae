require 'spec_helper'

feature 'Alt Text Manager' do

  scenario 'alt text can be edited inline', js: true do
    admin_login
    release = FactoryBot.create(:release)
    image = Fae::Image.create({
      imageable_type: 'Release', 
      imageable_id: release.id, 
      attached_as: 'bottle_shot'
    })
    visit fae.alt_texts_path

    expect(page).to have_content('No alt text')
    find('.js-edit-alt-button').click
    fill_in("alt_text_input_#{image.id}", with: 'New alt text')
    find('.js-save-alt-button').click
    expect(page).to have_content('New alt text')
    image.reload
    expect(image.alt).to eq('New alt text')
  end

  scenario 'alt text is not editable by non-admin users', js: true do
    user_login
    release = FactoryBot.create(:release)
    Fae::Image.create({
      imageable_type: 'Release', 
      imageable_id: release.id, 
      attached_as: 'bottle_shot'
    })
    visit fae.alt_texts_path

    within(".js-alt-text-label") do
      expect(page).to have_content('No alt text')
      expect(page).not_to have_selector('.js-edit-alt-button')
    end
  end

end