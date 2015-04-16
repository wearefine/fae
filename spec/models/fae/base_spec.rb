require 'rails_helper'
require 'pry'

describe Fae::Concerns::Models::Base do

  describe '#to_csv' do
    context 'when to_csv is run' do
      it 'it should return a csv with the correct data items' do
        release1 = FactoryGirl.create(:release, id: 1, release_date: Date.today)
        @items = Release.for_fae_index
        @csv = CSV.parse(@items.to_csv)
        expect(@csv.first) == Release.column_names

        Release.column_names.each do |field|
          if release1[field].present?
            expect(@csv.second).to include(release1[field].to_s)
          end
        end

      end
    end
  end

end