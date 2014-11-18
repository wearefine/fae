require 'rails_helper'

describe Fae::Option do

  describe '#instance' do
    context 'when no option object is present' do
      it 'should create a new instance' do
        starting_options = Fae::Option.all.length
        # Fae::Option.instance
        FactoryGirl.create(:fae_option)
        ending_options = Fae::Option.all.length

        expect(starting_options).to eq(0)
        expect(ending_options).to eq(1)
      end
    end
  end

end