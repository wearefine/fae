require 'rails_helper'

describe 'fae_filter_select' do

  describe 'label option' do
    it 'should default to attribute.to_s.titleize' do
      admin_login
      get admin_releases_path

      expect(response.body).to include('<label for="filter_wine">Wine</label>')
    end

    it 'should be overridable' do
      admin_login
      get admin_releases_path

      expect(response.body).to include('<label for="filter_acclaims">Acclaim</label>')
    end
  end

  describe 'label_method option' do
    it 'should default to :fae_display_field' do
      FactoryGirl.create(:wine, name_en: 'A Tasty Beverage')
      admin_login
      get admin_releases_path

      expect(response.body).to include('A Tasty Beverage')
    end

    it 'should be overridable' do
      FactoryGirl.create(:acclaim, score: 'A Tasty Acclaim', publication: 'A Tasty Publication')
      admin_login
      get admin_releases_path

      expect(response.body).to      include('A Tasty Acclaim')
      expect(response.body).to_not  include('A Tasty Publication')
    end
  end

  describe 'placeholder option' do
    it 'should default to "All Class Names" and be overridable' do
      admin_login
      get admin_releases_path

      expect(response.body).to include('All Wines')
      expect(response.body).to include('Select some stuff')
    end
  end

  describe 'grouped_options option' do
    it 'should generate opt groups based on grouped_options' do
      admin_login
      get admin_releases_path

      within('#filter_grouped_test') do
        expect(page).to have_css('optgroup[label="Numbers"]')
      end
    end
  end

  describe 'grouped_by option' do
    it 'should generate opt groups based on grouped_options' do
      admin_login
      get admin_releases_path

      within('#filter_grouped_association') do
        expect(page).to have_css('optgroup')
      end
    end
  end

end