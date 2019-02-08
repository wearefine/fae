require 'rails_helper'

describe Fae::ViewHelper do

  describe '#fae_date_format' do

    before(:each) do
      @option = Fae::Option.instance
    end

    context 'when passed nil' do
      it 'should return nil' do
        expect(fae_date_format(nil)).to eq(nil)
      end
    end

    context 'when passed a string' do
      it 'should return nil' do
        expect(fae_date_format('not a date')).to eq(nil)
      end
    end

    context 'when passed a date' do
      it 'should return the date formatted' do
        date = Date.parse('13/03/2015')
        expect(fae_date_format(date)).to eq('03/13/15')
      end
    end

    context 'when passed a datetime' do
      it 'should return the date formatted' do
        datetime = DateTime.parse('13th Mar 2015 04:05:06 PM')
        expect(fae_date_format(datetime)).to eq('03/13/15')
      end
    end

  end

  describe '#fae_datetime_format' do

    before(:each) do
      @option = Fae::Option.instance
    end

    context 'when passed nil' do
      it 'should return nil' do
        expect(fae_datetime_format(nil)).to eq(nil)
      end
    end

    context 'when passed a string' do
      it 'should return nil' do
        expect(fae_datetime_format('not a date')).to eq(nil)
      end
    end

    context 'when passed a date' do
      it 'should return the date formatted' do
        date = Date.parse('13/03/2015')
        expect(fae_datetime_format(date)).to eq('Mar 13, 2015 12:00am PDT')
      end
    end

    context 'when passed a datetime' do
      it 'should return the date formatted' do
        datetime = DateTime.parse('13th Mar 2015 04:05:06 PM PDT')
        expect(fae_datetime_format(datetime)).to eq('Mar 13, 2015  4:05pm PDT')
      end
    end

  end

  describe '#fae_avatar' do
    it 'should return a gravatar with the correct MD5 hash' do
      user = FactoryBot.create(:fae_user, email: 'fae_is_great@facts.com')

      expect( fae_avatar(user) ).to eq('https://secure.gravatar.com/avatar/d21c5b2c4ee9b417a9be23358ee14c91?s=80&d=mm')
    end
  end

  describe '#fae_delete_button' do
    # Necessary for fae_scope in the fae_delete_button method
    include Fae::ApplicationHelper

    it 'should include a polymorphic path when fae_parent is present' do
      item = FactoryBot.create(:coach)
      expect( fae_delete_button(item) ).to match /\/admin\/teams\/\d+\/coaches\/\d+/
    end

    it 'should include a regular path when fae_parent is not present' do
      item = FactoryBot.create(:release)
      expect( fae_delete_button(item) ).to match /\/admin\/releases\/\d+/
    end

    it 'should include a custom path when a second argument is supplied' do
      item = FactoryBot.create(:coach)

      # as a Rails path helper
      expect( fae_delete_button(item, ['admin', item.team, item]) ).to match /\/admin\/teams\/\d+\/coaches\/\d+/

      # as a string
      expect( fae_delete_button(item, '/admin/custom/route') ).to match /\/admin\/custom\/route/
    end

    it 'should allow custom attributes' do
      item = FactoryBot.create(:coach)

      expect( fae_delete_button(item, nil, custom_attribute: 'value') ).to match /custom_attribute="value"/
      # Supports deep_merge
      expect( fae_delete_button(item, nil, data: { custom_attribute: 'value' } ) ).to match /data-custom-attribute="value"/
    end

  end

  describe '#fae_sort_id' do
    it 'should return a formatted string for single word models' do
      item = FactoryBot.create(:varietal, id: 524)
      expect(fae_sort_id(item)).to eq('varietal_524')
    end

    it 'should return a formatted string for multiple word models' do
      item = FactoryBot.create(:selling_point, id: 235)
      expect(fae_sort_id(item)).to eq('selling_point_235')
    end

    it 'should return a formatted string for scoped models' do
      item = FactoryBot.create(:fae_user, id: 143)
      expect(fae_sort_id(item)).to eq('fae__user_143')
    end
  end

  describe '#fae_index_image' do
    it 'should return nothing if an asset is not present' do
      expect(fae_index_image(nil)).to eq(nil)
    end

    it 'should return an image tag without a link if an item but no path is provided' do
      @release = FactoryBot.create(:release)
      FactoryBot.create(:fae_image, imageable_type: 'Release', imageable_id: @release.id, attached_as: 'bottle_shot')
      expect(fae_index_image(@release.bottle_shot)).to include('<img')
      expect(fae_index_image(@release.bottle_shot)).to_not include('<a href')
    end

    it 'should return an image tag wrapped in a link when an item and a path are provided' do
      @release = FactoryBot.create(:release)
      FactoryBot.create(:fae_image, imageable_type: 'Release', imageable_id: @release.id, attached_as: 'bottle_shot')
      expect(fae_index_image(@release.bottle_shot, '/admin/custom/route')).to include('<img')
      expect(fae_index_image(@release.bottle_shot, '/admin/custom/route')).to include('<a href')
    end
  end

end
