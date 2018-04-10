require 'rails_helper'

describe Fae::TextField do

  describe 'concerns' do
    it 'should allow instance methods through Fae::TextFieldConcern' do
      text_field = FactoryGirl.build_stubbed(:fae_text_field)
      expect(text_field.instance_says_what).to eq('Fae::TextField instance: what?')
    end

    it 'should allow class methods through Fae::TextFieldConcern' do
      expect(Fae::TextField.class_says_what).to eq('Fae::TextField class: what?')
    end
  end

end
