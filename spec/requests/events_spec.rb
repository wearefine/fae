require 'rails_helper'

describe 'events#index' do

  it 'should return found' do
    admin_login
    get admin_events_path

    expect(response.status).to eq(500)
  end

end

describe 'events#new' do

  it 'should return found' do
    admin_login
    get new_admin_event_path

    expect(response.status).to eq(200)
  end

end

describe 'events#edit' do

  it 'should return found' do
    event = FactoryGirl.create(:event)
    admin_login
    get edit_admin_event_path(event)

    expect(response.status).to eq(200)
  end

end