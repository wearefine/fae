require 'rails_helper'

describe 'custom columns' do
  it 'should get correct title and attr' do
    release = FactoryGirl.create(:release)
    admin_login
    get edit_admin_release_path(release)

    expect(response.body).to include('Pew Pew')
    expect(response.body).to include('Kitten Count')
  end
end