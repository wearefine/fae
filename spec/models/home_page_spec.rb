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

      expect(home_page).to respond_to(:hero, :introduction, :body_copy_1, :body_copy_2, :body_copy_3, :body_copy_4, :body_copy_5, :body_copy_6, :body_copy_7, :body_copy_8, :body_copy_9, :body_copy_10, :hero_image, :welcome_pdf)
    end

    context 'default context method' do
      before(:each) do
        FactoryGirl.create(:home_page)
        @home_page = HomePage.instance
      end

      it 'should respond_to default method' do
        @home_page.create_hero(attached_as: 'hero')
        expect(@home_page.respond_to?(:hero_content)).to be_truthy
      end

      it 'should return assoc.content' do
        @home_page.create_hero(attached_as: 'hero', content: "You're my hero!!")
        expect(@home_page.hero_content).to eq("You're my hero!!")
      end

      it 'should do something' do
        expect(@home_page.hero).to be_nil
        expect(@home_page.hero_content).to be_nil
      end
    end

  end

end
