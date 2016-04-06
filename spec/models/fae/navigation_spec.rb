require 'rails_helper'

describe Fae::Navigation do

  describe '.side_nav' do
    it 'should return nil when current section is less than three levels' do
      nav = Fae::Navigation.new('/admin/content_blocks/home')

      expect(nav.side_nav).to be_nil
    end

    it 'should return the current sections third+ levels if present' do
      nav = Fae::Navigation.new('/admin/varietals')

      expect(nav.side_nav.map { |i| i[:text] }).to eq(['Varietals', 'Selling Points'])
    end
  end

  describe '.search' do
    it 'should return items by text in all levels of `structure`' do
      nav = Fae::Navigation.new('/admin')

      # this hash maps test queries (key) to excpected results (value)
      {
        'tio' => [
          { text: 'Locations', nested_path: '/admin/locations' },
          { text: 'Validation Testers', nested_path: '/admin/validation_testers' }
        ],
        'home'=> [
          {text: 'Home', nested_path: '/admin/content_blocks/home' }
        ],
        'event h' => [
          { text: 'Event Hosts', nested_path: '/admin/people' }
        ],
        'nope' => []
      }.each do |query, result|
        expect(nav.search(query)).to eq(result)
      end

    end
  end
end