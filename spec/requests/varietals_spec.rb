require 'rails_helper'

describe 'varietals#index' do

  it 'should return found' do
    admin_login
    get admin_varietals_path

    expect(response.status).to eq(200)
  end

end

describe 'varietals#new' do

  it 'should return found' do
    admin_login
    get new_admin_varietal_path

    expect(response.status).to eq(200)
  end

end

describe 'varietals#edit' do

  it 'should return found' do
    varietal = FactoryGirl.create(:varietal)
    admin_login
    get edit_admin_varietal_path(varietal)

    expect(response.status).to eq(200)
  end

end
