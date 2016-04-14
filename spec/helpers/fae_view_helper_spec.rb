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
      user = FactoryGirl.create(:fae_user, email: 'fae_is_great@facts.com')

      expect( fae_avatar(user) ).to eq('https://secure.gravatar.com/avatar/d21c5b2c4ee9b417a9be23358ee14c91?s=80&d=mm')
    end
  end

  describe '#fae_delete_button' do
    # Necessary for fae_scope in the fae_delete_button method
    include Fae::ApplicationHelper

    it 'should include a polymorphic path when fae_parent is present' do
      item = FactoryGirl.create(:coach)
      expect( fae_delete_button(item) ).to match /\/admin\/teams\/\d+\/coaches\/\d+/
    end

    it 'should include a regular path when fae_parent is not present' do
      item = FactoryGirl.create(:release)
      expect( fae_delete_button(item) ).to match /\/admin\/releases\/\d+/
    end

    it 'should include a custom path when a second argument is supplied' do
      item = FactoryGirl.create(:coach)

      # as a Rails path helper
      expect( fae_delete_button(item, ['admin', item.team, item]) ).to match /\/admin\/teams\/\d+\/coaches\/\d+/

      # as a string
      expect( fae_delete_button(item, '/admin/custom/route') ).to match /\/admin\/custom\/route/
    end
  end

end
