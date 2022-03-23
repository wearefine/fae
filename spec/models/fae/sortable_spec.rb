require 'rails_helper'

describe Fae::Sortable do

  describe 'fae_sort' do

    before(:each) do
      aroma1 = FactoryBot.create(:aroma, name: 'lavendar')
      aroma2 = FactoryBot.create(:aroma, name: 'rose')
      aroma3 = FactoryBot.create(:aroma, name: 'mint')

      @cat1 = FactoryBot.create(:cat, name: 'Hairold', aroma: aroma2)
      @cat2 = FactoryBot.create(:cat, name: 'Whiskurt', aroma: aroma2)
      @cat3 = FactoryBot.create(:cat, name: 'Faline', aroma: aroma1)
      @cat4 = FactoryBot.create(:cat, name: 'Dud', aroma: aroma3)

      @default_order = [@cat1, @cat2, @cat3, @cat4]
    end

    context 'if no sort params are passed' do
      it 'should return all items' do
        expect(Cat.fae_sort({})).to eq(@default_order)
      end
    end

    context 'if only sort_by param is passed' do
      it 'should sort by attribute' do
        expect(Cat.fae_sort({ sort_by: 'name' })).to eq([@cat4, @cat3, @cat1, @cat2])
      end

      it 'should sort by association attribute' do
        expect(Cat.fae_sort({ sort_by: 'aroma.name' })).to eq([@cat3, @cat4, @cat1, @cat2])
      end

      it "should ignore params that aren't an objects attribute" do
        expect(Cat.fae_sort({ sort_by: 'pasta' })).to eq(@default_order)
        expect(Cat.fae_sort({ sort_by: 'aroma.pasta' })).to eq(@default_order)
      end

      it "should ignore objects that aren't present" do
        expect(Cat.fae_sort({ sort_by: 'pasta.name' })).to eq(@default_order)
      end
    end

    context 'if both params are passed' do
      it 'should apply sort direction to attributes'  do
        expect(Cat.fae_sort({ sort_by: 'name', sort_direction: 'asc' })).to eq([@cat4, @cat3, @cat1, @cat2])
        expect(Cat.fae_sort({ sort_by: 'name', sort_direction: 'desc' })).to eq([@cat2, @cat1, @cat3, @cat4])
      end

      it 'should apply sort direction to association attributes'  do
        expect(Cat.fae_sort({ sort_by: 'aroma.name', sort_direction: 'asc' })).to eq([@cat3, @cat4, @cat1, @cat2])
        expect(Cat.fae_sort({ sort_by: 'aroma.name', sort_direction: 'desc' })).to eq([@cat1, @cat2, @cat4, @cat3])
      end

      it "should ignore sort_directions that aren't 'asc' or 'desc'" do
        expect(Cat.fae_sort({ sort_by: 'name', sort_direction: 'fishbowl' })).to eq([@cat4, @cat3, @cat1, @cat2])
      end
    end

    context 'if only sort_direction param is passed' do
      it 'should return all items' do
        expect(Cat.fae_sort({ sort_direction: 'desc' })).to eq(@default_order)
      end
    end

  end

end
