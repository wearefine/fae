require 'rails_helper'

describe 'people#index' do

  before do
    def admin_people_path
      Rails.application.routes.url_helpers.admin_people_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_people_path

    expect(response.status).to eq(200)
  end

end

describe 'people#new' do

  before do
    def new_admin_person_path
      Rails.application.routes.url_helpers.new_admin_person_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_person_path

    expect(response.status).to eq(200)
  end

end

describe 'people#edit' do

  before do
    def edit_admin_person_path(person)
      Rails.application.routes.url_helpers.edit_admin_person_path(person)
    end
  end

  it 'should return found' do
    person = FactoryBot.create(:person)
    admin_login
    get edit_admin_person_path(person)

    expect(response.status).to eq(200)
  end

end