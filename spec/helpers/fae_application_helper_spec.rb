require 'rails_helper'

describe Fae::ApplicationHelper do

  describe "#col_name_or_image" do

    before(:each) do
      @winemaker_image = FactoryBot.build(:fae_image, imageable_type: 'Winemaker', imageable_id: 1, attached_as: 'winemaker_image')
      @winemaker = FactoryBot.create(:winemaker, winemaker_image: @winemaker_image)
    end

    it 'should display an image tag for an image field' do
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("<img")
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("/system/uploads/fae/image/asset/#{@winemaker_image.id}/thumb_test.jpg")
    end

    it 'should display an image tag for an image field from a custom method' do
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("<img")
      expect(col_name_or_image(@winemaker, :winemaker_image)).to include("/system/uploads/fae/image/asset/#{@winemaker_image.id}/thumb_test.jpg")
    end
  end

  describe "#change_item_link" do

    it 'should display a link with data from the fae_dispaly_field if its a string or an integer' do
      @user = FactoryBot.build_stubbed(:fae_user)
      @item = FactoryBot.build_stubbed(:milestone, year: 2016)
      @change = FactoryBot.build_stubbed(:fae_change, changeable: @item, user: @user )

      @item2 = FactoryBot.build_stubbed(:varietal, name: "Example Name")
      @change2 = FactoryBot.build_stubbed(:fae_change, changeable: @item2, user: @user )

      expect(change_item_link(@change)).to include("Milestone: 2016")
      expect(change_item_link(@change2)).to include("Varietal: Example Name")

    end

    it 'should display the changeable_id for the item field if changeable items fae_dispaly_field is nil' do

      @user = FactoryBot.build_stubbed(:fae_user)
      @item = FactoryBot.build_stubbed(:varietal, name: nil)
      @change = FactoryBot.build_stubbed(:fae_change, changeable: @item, user: @user )
      @item2 = FactoryBot.build_stubbed(:milestone, year: nil)
      @change2 = FactoryBot.build_stubbed(:fae_change, changeable: @item2, user: @user )

      expect(change_item_link(@change)).to include("Varietal: ##{@item.id}")
      expect(change_item_link(@change2)).to include("Milestone: ##{@item2.id}")

    end
  end

end
