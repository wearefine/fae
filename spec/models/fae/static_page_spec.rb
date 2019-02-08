require 'rails_helper'

describe Fae::StaticPage do

  describe 'concerns' do
    it 'should allow instance methods through Fae::StaticPageConcern' do
      static_page = FactoryBot.build_stubbed(:fae_static_page)

      expect(static_page.instance_says_what).to eq('Fae::StaticPage instance: what?')
    end

    it 'should allow class methods through Fae::StaticPageConcern' do
      expect(Fae::StaticPage.class_says_what).to eq('Fae::StaticPage class: what?')
    end
  end

  describe 'dynamic associations' do

    it 'should attach only once' do
      hp = HomePage.instance
      expect(hp.class.reflect_on_all_associations(:has_one).map(&:name)).to eq([:header, :hero, :email, :phone, :cell_phone, :work_phone, :introduction, :introduction_2, :body, :hero_image, :welcome_pdf])

      # trigger instance twice
      hp = HomePage.instance
      expect(hp.class.reflect_on_all_associations(:has_one).map(&:name)).to eq([:header, :hero, :email, :phone, :cell_phone, :work_phone, :introduction, :introduction_2, :body, :hero_image, :welcome_pdf])
    end

    it 'should attach language associations when present' do
      ap = AboutUsPage.instance

      expect(ap.body_en).to be_nil
      expect(ap.body_zh).to be_nil

      expect(ap.header_image_zh).to be_nil
    end

  end

  describe 'dynamic validations' do

    it 'should only attach once' do
      # trigger multiple instances which add dynamic validations to associated objects
      AboutUsPage.instance
      HomePage.instance
      HomePage.instance

      home_page_validations = Fae::TextField.validators_on(:content).keep_if do |v|
        v.options[:if].to_s['is_home_page']
      end
      expect(home_page_validations.map { |v| v.class.name }).to eq(['ActiveRecord::Validations::PresenceValidator', 'ActiveModel::Validations::FormatValidator'])
    end

  end

  describe 'as_json' do

    before(:each) do
      @home_page = HomePage.instance
    end

    it 'should return associated attributes' do
      expect(@home_page.as_json).to have_key(:header)
      expect(@home_page.as_json).to have_key(:hero)
      expect(@home_page.as_json).to have_key(:email)
      expect(@home_page.as_json).to have_key(:phone)
      expect(@home_page.as_json).to have_key(:introduction)
      expect(@home_page.as_json).to have_key(:introduction_2)
      expect(@home_page.as_json).to have_key(:body)
      expect(@home_page.as_json).to have_key(:hero_image)
      expect(@home_page.as_json).to have_key(:welcome_pdf)
    end

    it 'should return Fae::TextField and Fae::TextArea associtaions as content' do
      @home_page.create_header(attached_as: 'header', content: 'Some real good Fae::TextField content')
      @home_page.create_introduction(attached_as: 'introduction', content: 'Some real good Fae::TextArea content')

      expect(@home_page.as_json[:header]).to eq('Some real good Fae::TextField content')
      expect(@home_page.as_json[:introduction]).to eq('Some real good Fae::TextArea content')
    end

    it 'should return Fae::Image and Fae::File association as a hash' do
      home_page_image = FactoryBot.create(:fae_image, caption: 'look, a mountain', imageable_type: 'Fae::StaticPage', imageable_id: @home_page.id, attached_as: 'hero_image')
      home_page_file = FactoryBot.create(:fae_file, fileable_type: 'Fae::StaticPage', fileable_id: @home_page.id, attached_as: 'welcome_pdf')

      expect(@home_page.as_json[:hero_image]).to have_key('asset')
      expect(@home_page.as_json[:hero_image]['asset']['url']).to include('test.jpg')
      expect(@home_page.as_json[:hero_image]['caption']).to eq('look, a mountain')
      expect(@home_page.as_json[:welcome_pdf]).to have_key('asset')
      expect(@home_page.as_json[:welcome_pdf]['asset']['url']).to include('test.pdf')
    end

  end

  describe 'when decorated' do
    it 'should respond to decorator method' do
      static_page = FactoryBot.build_stubbed(:fae_static_page)

      expect(static_page.respond_to?('instance_is_decorated')).to eq true
      expect(static_page.instance_is_decorated).to eq('Fae::StaticPage instance is decorated')
    end
  end

  describe '.supports_validation' do
    
    context 'when the type is supported' do
      it 'should return false without validates hash' do
        expect(Fae::StaticPage.supports_validation(Fae::TextField, Fae::TextField)).to eq(false)
        expect(Fae::StaticPage.supports_validation(Fae::TextField, { type: Fae::TextField })).to eq(false)
      end

      it 'should return true with validates hash' do
        value = { type: Fae::TextField, validates: { presence: true } }
        expect(Fae::StaticPage.supports_validation(Fae::TextField, value)).to eq(true)
      end
    end

    context 'when the type is not supported' do
      it 'should always return false' do
        without_validates = { type: Fae::File }
        with_validates = { type: Fae::Image, validates: { presence: true } }
        expect(Fae::StaticPage.supports_validation(Fae::File, without_validates)).to eq(false)
        expect(Fae::StaticPage.supports_validation(Fae::Image, with_validates)).to eq(false)
      end
    end
  end

end
