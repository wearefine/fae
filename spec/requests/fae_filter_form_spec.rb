require 'rails_helper'

describe 'fae_filter_form' do

  describe 'title option' do
    it 'should default to "Search Class Names"' do
      admin_login
      get admin_releases_path

      expect(response.body).to include('Search Releases')
    end

    it 'should be overridable' do
      admin_login
      get admin_locations_path

      expect(response.body).to include('Disregard, just testing filter options')
    end
  end

  describe 'search option' do
    it 'should default to showing the search field' do
      admin_login
      get admin_releases_path

      expect(response.body).to include('Search by Keyword')
    end

    it 'should not show search if search: false' do
      admin_login
      get admin_locations_path

      expect(response.body).to_not include('Search by Keyword')
    end
  end

end