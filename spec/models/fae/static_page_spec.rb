require 'rails_helper'

describe Fae::StaticPage do

  describe 'concerns' do
    it 'should allow instance methods through Fae::StaticPageConcern' do
      static_page = FactoryGirl.create(:fae_static_page)

      expect(static_page.instance_says_what).to eq('Fae::StaticPage instance: what?')
    end

    it 'should allow class methods through Fae::StaticPageConcern' do
      expect(Fae::StaticPage.class_says_what).to eq('Fae::StaticPage class: what?')
    end
  end

  describe 'dynamic associations' do

    it 'should attach only once' do
      hp = HomePage.instance
      expect(hp.class.reflect_on_all_associations(:has_one).map(&:name)).to eq([:header, :hero, :email, :phone, :introduction, :introduction_2, :body, :hero_image, :welcome_pdf])

      # trigger instance twice
      hp = HomePage.instance
      expect(hp.class.reflect_on_all_associations(:has_one).map(&:name)).to eq([:header, :hero, :email, :phone, :introduction, :introduction_2, :body, :hero_image, :welcome_pdf])
    end

    it 'should attach language associations when present' do
      ap = AboutUsPage.instance

      expect(ap.body_en).to be_nil
      expect(ap.body_zh).to be_nil

      expect(ap.header_image_zh).to be_nil
    end

    # TODO - This test fails occaisionally, and those failures appear to be related to test order (likely related to changing I18n.locale). Temporarily commented out.
    # it 'should use _content to query the field with the desired I18n locale' do
    #   I18n.locale = :zh

    #   cp = ContactUsPage.instance
    #   cp.create_body_en(content: 'test en')
    #   cp.create_body_zh(content: 'test zh')

    #   expect(cp.body_content).to eq('test zh')

    #   I18n.locale = :en
    # end

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

end