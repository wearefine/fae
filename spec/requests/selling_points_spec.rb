require 'rails_helper'

describe 'selling_points#index' do

  it 'should return found' do
    admin_login
    get admin_selling_points_path

    expect(response.status).to eq(200)
  end

end

describe 'selling_points#new' do

  it 'should return found' do
    admin_login
    get new_admin_selling_point_path

    expect(response.status).to eq(200)
  end

end

describe 'selling_points#edit' do

  it 'should return found' do
    selling_point = FactoryBot.create(:selling_point)
    admin_login
    get edit_admin_selling_point_path(selling_point)

    expect(response.status).to eq(200)
  end

end