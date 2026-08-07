require 'rails_helper'

describe 'privacy_pages#edit' do
  it 'should return found' do
    admin_login
    get edit_admin_privacy_page_path

    expect(response.status).to eq(200)
  end
end

describe 'privacy_pages#update' do
  it 'persists updates on the singleton row' do
    admin_login
    patch admin_privacy_page_path, params: {
      privacy_page: {
        title: 'Privacy Policy',
        headline: 'Your data',
        body: 'Sample content'
      }
    }

    expect(response).to redirect_to(edit_admin_privacy_page_path)
    expect(PrivacyPage.first&.title).to eq('Privacy Policy')
  end
end
