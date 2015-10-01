require 'rails_helper'

describe Fae::Trackable do

  describe 'after_create' do
    it 'should create a change item related to the model' do
      wine = FactoryGirl.create(:wine)

      change = Fae::Change.last
      expect(change.changeable_id).to eq(wine.id)
      expect(change.changeable_type).to eq('Wine')
      expect(change.change_type).to eq('created')
    end
  end

  describe 'before_update' do
    it 'should create a change item related to the model' do
      wine = FactoryGirl.create(:wine)
      wine.update({name_en: 'new name', description_en: 'new desc', food_pairing_en: 'new pairing'})

      change = Fae::Change.last
      expect(change.changeable_id).to eq(wine.id)
      expect(change.changeable_type).to eq('Wine')
      expect(change.change_type).to eq('updated')
      expect(change.updated_attributes).to eq(['name_en', 'description_en', 'food_pairing_en'])
    end

    it 'should not create item if no changes were made' do
      wine = FactoryGirl.create(:wine, name_en: 'test')
      wine.update({name_en: 'test'})

      change = Fae::Change.last
      expect(change.changeable_id).to eq(wine.id)
      expect(change.changeable_type).to eq('Wine')
      expect(change.change_type).to eq('created')
    end
  end

  describe 'before_destroy' do
    it 'should create a change item related to the model' do
      wine = FactoryGirl.create(:wine)
      wine.destroy

      change = Fae::Change.last
      expect(change.changeable_id).to eq(wine.id)
      expect(change.changeable_type).to eq('Wine')
      expect(change.change_type).to eq('deleted')
    end
  end

  describe 'tracked_changes' do
    it 'should assign association to parent object' do
      wine = FactoryGirl.create(:wine)
      wine.update({name_en: 'testttt'})
      expect(wine.tracked_changes.length).to eq(2)
    end

    it 'should assign no more than Fae.tracker_history_length changes' do
      wine = FactoryGirl.create(:wine, name_en: 'change 1')
      wine.update({name_en: 'change 2'})
      wine.update({name_en: 'change 3'})
      wine.update({name_en: 'change 4'})
      wine.update({name_en: 'change 5'})
      wine.update({name_en: 'change 6'})
      wine.update({name_en: 'change 7'})
      wine.update({name_en: 'change 8'})
      wine.update({name_en: 'change 9'})
      wine.update({name_en: 'change 10'})
      wine.update({name_en: 'change 11'})
      wine.update({name_en: 'change 12'})
      wine.update({name_en: 'change 13'})
      wine.update({name_en: 'change 14'})
      wine.update({name_en: 'change 15'})
      wine.update({name_en: 'change 16'})
      wine.update({description_en: 'change 17'})

      expect(wine.tracked_changes.length).to eq(Fae.tracker_history_length)
      expect(wine.tracked_changes.first.updated_attributes).to eq(['description_en'])
    end
  end

end