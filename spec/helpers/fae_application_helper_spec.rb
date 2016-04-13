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

  # describe "#change_item_link" do

  #   it 'should display a number for the item field' do

  #     admin_login
  #     @item = FactoryGirl.create(:varietal, name: 2016)
  #     @change = FactoryGirl.build(:fae_change, changeable: @item, user: current_user )

  #     expect(change_item_link(@change)).to include("Varietel: 2016")

  #   end

  #   it 'should display a string for the item field' do

  #     admin_login
  #     @item = FactoryGirl.create(:varietal, name: "Varietal Example Name 2016")
  #     @change = FactoryGirl.build(:fae_change, changeable: @item, user: current_user )

  #     expect(change_item_link(@change)).to include("Varietel: Varietal Example Name 2016")

  #   end


  #   it 'should display the Changeable_id for the item field if changeable items fae_dispaly_field is nil' do

  #     admin_login
  #     @item = FactoryGirl.create(:varietal, name: nil)
  #     @change = FactoryGirl.build(:fae_change, changeable: @item, user: current_user )

  #     expect(change_item_link(@change)).to include("Varietel: #{@item.id}")

  #   end

  end

end
