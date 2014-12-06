require 'rails_helper'

describe HomePage do

  describe '#instance' do
    context 'when no option object is present' do
      it 'should create a new instance' do
        home_page_length_before = HomePage.all.length
        home_page = HomePage.instance
        home_page_length_after = HomePage.all.length

        expect(home_page_length_before).to eq(0)
        expect(home_page_length_after).to eq(1)
      end
    end

    context 'when an option object is present' do
      it 'should return the instance' do
        FactoryGirl.create(:home_page)
        home_page_length_before = HomePage.all.length
        home_page = HomePage.instance
        home_page_length_after = HomePage.all.length

        expect(home_page_length_before).to eq(1)
        expect(home_page_length_after).to eq(1)
        expect(home_page).to be_a HomePage
      end
    end

    it 'should have all associations from #fae_fields' do
      FactoryGirl.create(:home_page)
      home_page = HomePage.instance

      expect(home_page).to respond_to(:hero, :introduction, :body_copy_1, :body_copy_2, :body_copy_3, :body_copy_4, :body_copy_5, :body_copy_6, :body_copy_7, :body_copy_8, :body_copy_9, :body_copy_10, :hero_image, :welocme_pdf)
    end
  end

end