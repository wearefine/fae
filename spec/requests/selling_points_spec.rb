require 'rails_helper'

describe 'selling_points#index' do

  before do
    def admin_selling_points_path
      Rails.application.routes.url_helpers.admin_selling_points_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_selling_points_path

    expect(response.status).to eq(200)
  end

end

describe 'selling_points#new' do

  before do
    def new_admin_selling_point_path
      Rails.application.routes.url_helpers.new_admin_selling_point_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_selling_point_path

    expect(response.status).to eq(200)
  end

end

describe 'selling_points#edit' do

  before do
    def edit_admin_selling_point_path(selling_point)
      Rails.application.routes.url_helpers.edit_admin_selling_point_path(selling_point)
    end
  end

  it 'should return found' do
    selling_point = FactoryBot.create(:selling_point)
    admin_login
    get edit_admin_selling_point_path(selling_point)

    expect(response.status).to eq(200)
  end

end