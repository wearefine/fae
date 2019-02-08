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
        FactoryBot.create(:home_page)
        home_page_length_before = HomePage.all.length
        home_page = HomePage.instance
        home_page_length_after = HomePage.all.length

        expect(home_page_length_before).to eq(1)
        expect(home_page_length_after).to eq(1)
        expect(home_page).to be_a HomePage
      end
    end

    it 'should have all associations from #fae_fields' do
      FactoryBot.create(:home_page)
      home_page = HomePage.instance

      expect(home_page).to respond_to(:hero, :introduction, :body, :welcome_pdf)
    end

    context 'when association has been created' do
      before(:each) do
        FactoryBot.create(:home_page)
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
    end

    context 'when assocation has not been created' do
      it 'hero_content should return nil' do
        FactoryBot.create(:home_page)
        home_page = HomePage.instance
        expect(home_page.hero_content).to be_nil
      end
    end

  end

end
