require 'rails_helper'

describe 'people#index' do

  it 'should return found' do
    admin_login
    get admin_people_path

    expect(response.status).to eq(200)
  end

end

describe 'people#new' do

  it 'should return found' do
    admin_login
    get new_admin_person_path

    expect(response.status).to eq(200)
  end

end

describe 'people#edit' do

  it 'should return found' do
    person = FactoryGirl.create(:person)
    admin_login
    get edit_admin_person_path(person)

    expect(response.status).to eq(200)
  end

end