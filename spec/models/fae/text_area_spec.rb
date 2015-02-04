require 'rails_helper'

describe Fae::TextArea do

  describe 'concerns' do
    it 'should allow instance methods through Fae::TextAreaConcern' do
      text_area = FactoryGirl.create(:fae_text_area)

      expect(text_area.instance_says_what).to eq('Fae::TextArea instance: what?')
    end

    it 'should allow class methods through Fae::TextAreaConcern' do
      expect(Fae::TextArea.class_says_what).to eq('Fae::TextArea class: what?')
    end
  end

end