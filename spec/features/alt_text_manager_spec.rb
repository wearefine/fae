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
    find('span', text: 'No alt text').click
    find(:css, ".alt_text_input").set('Actual alt text')
    find(:css, ".alt_text_input").trigger('blur')
    eventually { expect(page).to have_content('Actual alt text') }
    image.reload
    expect(image.alt).to eq('Actual alt text')
  end

end
