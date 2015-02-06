require 'rails_helper'

describe Fae::Image do

  describe 'concerns' do
    it 'should allow instance methods through Fae::ImageConcern' do
      image = FactoryGirl.create(:fae_image)

      expect(image.instance_says_what).to eq('Fae::Image instance: what?')
    end

    it 'should allow class methods through Fae::ImageConcern' do
      expect(Fae::Image.class_says_what).to eq('Fae::Image class: what?')
    end
  end

end