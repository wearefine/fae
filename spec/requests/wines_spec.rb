require 'rails_helper'

describe 'wines#index' do

  it 'should return found' do
    admin_login
    get admin_wines_path

    expect(response.status).to eq(200)
  end

end

describe 'wines#new' do

  it 'should return found' do
    admin_login
    get new_admin_wine_path

    expect(response.status).to eq(200)
  end

end

describe 'wines#edit' do

  it 'should return found' do
    wine = FactoryGirl.create(:wine)
    admin_login
    get edit_admin_wine_path(wine)

    expect(response.status).to eq(200)
  end

end