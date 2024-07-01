require 'rails_helper'

describe 'custom columns' do

  before do
    def edit_admin_release_path(release)
      Rails.application.routes.url_helpers.edit_admin_release_path(release)
    end
  end

  it 'should get correct title and attr' do
    release = FactoryBot.create(:release)
    admin_login
    get edit_admin_release_path(release)

    expect(response.body).to include('Pew Pew')
    expect(response.body).to include('Kitten Count')
  end
end