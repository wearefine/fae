require 'rails_helper'

describe Fae::BaseModelConcern do

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

  describe '#fae_nested_parent' do
    context 'when defined in a model' do
      it 'should return a symbol' do
        aroma = Aroma.new
        expect(aroma.fae_nested_parent).to eq(:release)
      end
    end

    context 'when not defined in a model' do
      it 'should return nil' do
        release = Release.new
        expect(release.fae_nested_parent).to eq(nil)
      end
    end
  end

  describe '#fae_nested_foreign_key' do
    context 'when #fae_nested_parent is defined in a model' do
      it 'should return a foreign key' do
        aroma = Aroma.new
        expect(aroma.fae_nested_foreign_key).to eq('release_id')
      end
    end

    context 'when #fae_nested_parent is not defined in a model' do
      it 'should return nil' do
        release = Release.new
        expect(release.fae_nested_foreign_key).to eq(nil)
      end
    end
  end

  describe '#translate' do
    it 'should translate specified attributes' do
      wine = Wine.new

      expect(wine.name).to eq( wine.send("name_#{I18n.locale}") )

      # Description is not explicitly translated even though it has international attributes
      expect( wine.try(:description) ).to eq(nil)
    end

    it 'should find_by translated attribute' do
      wine = FactoryGirl.create(:wine, name_en: 'Funky', name_zh: 'Funky', name_ja: 'Funky')

      expect( Wine.find_by_name('Funky') ).to be_present
    end
  end

end
