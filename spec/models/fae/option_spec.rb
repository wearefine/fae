require 'rails_helper'

describe Fae::Option do

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:time_zone) }
  it { should validate_presence_of(:live_url) }

  describe '#instance' do
    context 'when no option object is present' do
      it 'should create a new instance' do
        starting_options = Fae::Option.all.length
        options = Fae::Option.instance
        ending_options = Fae::Option.all.length

        expect(starting_options).to eq(0)
        expect(ending_options).to eq(1)
        expect(options).to be_a Fae::Option
      end
    end

    context 'when an option object is present' do
      it 'should return the instance' do
        options = Fae::Option.new(title: 'Test Title')

        expect(options).to be_a Fae::Option
        expect(options.title).to eq('Test Title')
      end
    end
  end

  describe 'concerns' do
    it 'should allow instance methods through Fae::OptionConcern' do
      option = Fae::Option.new
      expect(option.instance_says_what).to eq('Fae::Option instance: what?')
    end

    it 'should allow class methods through Fae::OptionConcern' do
      expect(Fae::Option.class_says_what).to eq('Fae::Option class: what?')
    end
  end

end