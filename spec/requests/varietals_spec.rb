require 'rails_helper'

describe 'varietals#index' do

  before do
    def admin_varietals_path
      Rails.application.routes.url_helpers.admin_varietals_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_varietals_path

    expect(response.status).to eq(200)
  end

end

describe 'varietals#new' do

  before do
    def new_admin_varietal_path
      Rails.application.routes.url_helpers.new_admin_varietal_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_varietal_path

    expect(response.status).to eq(200)
  end

end

describe 'varietals#edit' do

  before do
    def edit_admin_varietal_path(varietal)
      Rails.application.routes.url_helpers.edit_admin_varietal_path(varietal)
    end
  end

  it 'should return found' do
    varietal = FactoryBot.create(:varietal)
    admin_login
    get edit_admin_varietal_path(varietal)

    expect(response.status).to eq(200)
  end

end
