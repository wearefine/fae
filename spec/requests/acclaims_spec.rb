require 'rails_helper'

describe 'acclaims#index' do

  it 'should return found' do
    admin_login
    get admin_acclaims_path
    raise up

    expect(response.status).to eq(200)
  end

end

describe 'acclaims#new' do

  it 'should return found' do
    admin_login
    get new_admin_acclaim_path

    expect(response.status).to eq(200)
  end

end

describe 'acclaims#edit' do

  it 'should return found' do
    acclaim = FactoryGirl.create(:acclaim)
    admin_login
    get edit_admin_acclaim_path(acclaim)

    expect(response.status).to eq(200)
  end

end