require 'rails_helper'

describe Fae::ApplicationHelper do

  describe "#col_name_or_image" do

    before(:each) do
      @winemakerimage1 = FactoryGirl.build(:fae_image, imageable_type: 'Winemaker', imageable_id: 1, attached_as: 'winemaker_image')
      @winemaker1 = FactoryGirl.create(:winemaker, winemaker_image: @winemakerimage1)
    end

    it 'should display an image tag for an image field' do
      expect(col_name_or_image(@winemaker1, :winemaker_image)).to eq("<img src=\"/system/uploads/fae/image/asset/1/thumb_test.jpeg\" alt=\"Thumb test\" />")
    end

    it 'should display an image tag for an image field from a custom method' do
      expect(col_name_or_image(@winemaker1, :table_image)).to eq("<img src=\"/system/uploads/fae/image/asset/2/thumb_test.jpeg\" alt=\"Thumb test\" />")
    end
  end

end