require 'rails_helper'

describe 'events#index' do

  before do
    def admin_events_path
      Rails.application.routes.url_helpers.admin_events_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_events_path

    expect(response.status).to eq(200)
  end

end

describe 'events#new' do

  before do
    def new_admin_event_path
      Rails.application.routes.url_helpers.new_admin_event_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_event_path

    expect(response.status).to eq(200)
  end

end

describe 'events#edit' do

  before do
    def edit_admin_event_path(event)
      Rails.application.routes.url_helpers.edit_admin_event_path(event)
    end
  end

  it 'should return found' do
    event = FactoryBot.create(:event)
    admin_login
    get edit_admin_event_path(event)

    expect(response.status).to eq(200)
  end

end