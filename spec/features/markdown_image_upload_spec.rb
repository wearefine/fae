require 'spec_helper'

feature 'Markdown Image Uploads' do

  scenario 'should upload image when dropping into markdown text field', js: true do
    release = FactoryBot.create(:release)
    admin_login
    visit edit_admin_release_path(release)

    # Generate a fake input selector
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS

    # attach file to fake input
    attach_file("fakeFileInput", Rails.root + 'public/test.jpg')
    
    # Add the file to a fileList array
    page.execute_script("var fileList = [fakeFileInput.get(0).files[0]]")

    # Trigger the fake drop event
    page.execute_script <<-JS
      var e = jQuery.Event('drop', { dataTransfer : { files : [fakeFileInput.get(0).files[0]] } });
      $('.release_intro .CodeMirror')[0].CodeMirror._handlers.drop[0](null, e);
    JS

    eventually {
      expect(find('.release_intro .CodeMirror-code')).to have_content('/system/uploads/fae/image/asset')
    }
  end

end