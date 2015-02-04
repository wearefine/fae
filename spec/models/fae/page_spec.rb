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

end