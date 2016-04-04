require 'rails_helper'

describe Fae::Navigation do

  describe '.sidenav' do
    it 'should return nil on new and edit forms'
    it 'should return nil when current section is less than three levels'
    it 'should return the current sections third+ levels if present'
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