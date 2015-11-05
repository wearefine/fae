require 'rails_helper'

describe Fae::ApplicationHelper do

  describe "#col_name_or_image" do

    before(:each) do
      @winemaker_image = FactoryGirl.build(:fae_image, imageable_type: 'Winemaker', imageable_id: 1, attached_as: 'winemaker_image')
      @winemaker = FactoryGirl.create(:winemaker, winemaker_image: @winemaker_image)
    end

    it 'should display an image tag for an image field' do
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("<img")
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("/system/uploads/fae/image/asset/#{@winemaker_image.id}/thumb_test.jpeg")
    end

    it 'should display an image tag for an image field from a custom method' do
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("<img")
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("/system/uploads/fae/image/asset/#{@winemaker_image.id}/thumb_test.jpeg")
    end
  end

end
