require 'rails_helper'

describe 'recent_changes partial' do

  it 'should not display on new forms' do
    admin_login
    get new_admin_release_path

    expect(response.body).to_not include('Recent Changes')
  end

  it 'should display on edit forms' do
    release = FactoryBot.create(:release)

    admin_login
    get edit_admin_release_path(release)

    expect(response.body).to include('Recent Changes')
  end

end
