require 'rails_helper'

describe 'acclaims#index' do

  before do
    def admin_acclaims_path
      Rails.application.routes.url_helpers.admin_acclaims_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_acclaims_path

    expect(response.status).to eq(200)
  end

end

describe 'acclaims#new' do

  before do
    def new_admin_acclaim_path
      Rails.application.routes.url_helpers.new_admin_acclaim_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_acclaim_path

    expect(response.status).to eq(200)
  end

end

describe 'acclaims#edit' do

  before do
    def edit_admin_acclaim_path(acclaim)
      Rails.application.routes.url_helpers.edit_admin_acclaim_path(acclaim)
    end
  end

  it 'should return found' do
    acclaim = FactoryBot.create(:acclaim)
    admin_login
    get edit_admin_acclaim_path(acclaim)

    expect(response.status).to eq(200)
  end

end