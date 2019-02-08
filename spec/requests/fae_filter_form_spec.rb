require 'rails_helper'

describe 'fae_filter_form' do

  describe 'title option' do

    it 'should default to "Search Class Names"' do
      FactoryBot.create(:release)
      admin_login
      get admin_releases_path

      expect(response.body).to include('Search Releases')
    end

    it 'should be overridable' do
      FactoryBot.create(:location)
      admin_login
      get admin_locations_path

      expect(response.body).to include('Disregard, just testing filter options')
    end
  end

  describe 'search option' do
    it 'should default to showing the search field' do
      FactoryBot.create(:release)
      admin_login
      get admin_releases_path

      expect(response.body).to include('Search by Keyword')
    end

    it 'should not show search if search: false' do
      FactoryBot.create(:location)
      admin_login
      get admin_locations_path

      expect(response.body).to_not include('Search by Keyword')
    end
  end

  describe 'no records for the model' do
    it 'should not show filters' do
      admin_login

      # No records
      get admin_releases_path
      expect(response.body).to_not include('js-filter-form')

      # Ensure results display when there are records
      FactoryBot.create(:release)
      get admin_releases_path
      expect(response.body).to include('js-filter-form')
    end
  end

end