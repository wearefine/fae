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
        puts @option.time_zone
        datetime = DateTime.parse('13th Mar 2015 04:05:06 PM PDT')
        expect(fae_datetime_format(datetime)).to eq('Mar 13, 2015  4:05pm PDT')
      end
    end

  end

end