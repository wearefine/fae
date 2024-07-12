require 'rails_helper'

describe 'wines#index' do

  before do
    def admin_wines_path
      Rails.application.routes.url_helpers.admin_wines_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_wines_path

    expect(response.status).to eq(200)
  end

end

describe 'wines#new' do

  before do
    def new_admin_wine_path
      Rails.application.routes.url_helpers.new_admin_wine_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_wine_path

    expect(response.status).to eq(200)
  end

end

describe 'wines#create' do

  it 'acts_as_list should create wines with proper position attrs' do
    wine1 = FactoryBot.create(:wine)
    wine2 = FactoryBot.create(:wine)
    expect(wine1.reload.position).to eq(2)
    expect(wine2.reload.position).to eq(1)
  end

end

describe 'wines#edit' do

  before do
    def edit_admin_wine_path(wine)
      Rails.application.routes.url_helpers.edit_admin_wine_path(wine)
    end
  end

  it 'should return found' do
    wine = FactoryBot.create(:wine)
    admin_login
    get edit_admin_wine_path(wine)

    expect(response.status).to eq(200)
  end

end