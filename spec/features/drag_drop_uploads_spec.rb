require 'spec_helper'

feature 'Drag and drop uploads for file fields' do

  # uncomment to expose browser console error messages in terminal
  # very helpful for debugging as not all errors show up when page.driver.enable_logging is enabled
  # after(:each) do
  #   errors = [page.driver.error_messages, page.driver.console_messages]
  #   if errors.present?
  #     puts '-----------------------------'
  #     puts errors
  #   end
  # end

  before(:each) do 
    release = FactoryBot.create(:release)
    admin_login
    visit edit_admin_release_path(release)
  end
  
  def drop_image(image_field)
    # uncomment to debug js errors
    # page.driver.enable_logging

    # Generate a fake input selector
    page.execute_script <<-JS
      $fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
  
    # attach file to fake input
    attach_file("fakeFileInput", 'spec/support/assets/test-2.jpg')
  
    page.execute_script <<-JS
      // Ideal solution would be using 'dataTransfer` object along with 'DragEvent' event in vanilla JS but Capybara webkit driver does not have access to either of those so jquery event must be used instead
      var testEvent = jQuery.Event('drop', { dataTransfer : { files : $fakeFileInput.get(0).files } });
      $('#{image_field}').trigger(testEvent)
      JS
  end


  scenario 'should add image to input field when dropped', js: true do
    drop_image('.hero_image')
    expect(find('.hero_image .asset-actions span')).to have_content('test-2.jpg')
  end

  scenario 'should overwrite existing image when new image is dropped', js: true do
    # make input visible so capybara can attach file
    page.execute_script("$('#release_hero_image_attributes_asset').css({visibility: 'visible', position: 'static'}) ")
    attach_file('release_hero_image_attributes_asset', 'spec/support/assets/test.jpg')
    expect(find('.hero_image .asset-actions span')).to have_content('test.jpg')

    drop_image('.hero_image')
    expect(find('.hero_image .asset-actions span')).to have_content('test-2.jpg')
  end


end 