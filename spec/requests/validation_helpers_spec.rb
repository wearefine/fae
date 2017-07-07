require 'rails_helper'

describe 'validation_testers#new' do

  before(:each) do
    admin_login
    get new_admin_validation_tester_path
  end

  ### REGEX HELPERS ###
  context 'when using slug regex helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, slug: 'validation-tester-1')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, slug: 'validation-tester 2')

      expect(test).to_not be_valid
    end

  end

  context 'when using email regex helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, email: 'test@testsite.com')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, email: 'testemail @gmail.com')

      expect(test).to_not be_valid
    end

  end

  context 'when using url regex helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, url: 'http://poop.bike/')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, url: 'poop.bike')

      expect(test).to_not be_valid
    end

  end

  context 'when using zip regex helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, zip: '97214')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, zip: 'apple pie')

      expect(test).to_not be_valid
    end

  end

  context 'when using youtube regex helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, youtube_url: 'ZwBRX_h3U1U')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, youtube_url: '1cat')

      expect(test).to_not be_valid
    end

  end

  context 'when using slug hash helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester)

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, second_slug: 'some slug')

      expect(test).to_not be_valid
    end

  end

  context 'when using email hash helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, second_email: 'email@test.com')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, second_email: 'email/email.com')

      expect(test).to_not be_valid
    end

  end

  context 'when using url hash helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, second_url: 'http://poop.bike/')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, second_url: 'poop.bike')

      expect(test).to_not be_valid
    end

  end

  context 'when using zip hash helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, second_zip: '97214')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, second_zip: '124!0')

      expect(test).to_not be_valid
    end

  end

  context 'when using youtube hash helpers' do

    it 'should not throw error' do
      FactoryGirl.create(:validation_tester, second_youtube_url: 'ZwBRX_h3U1U')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      test = FactoryGirl.build(:validation_tester, second_youtube_url: '1cat')

      expect(test).to_not be_valid
    end

  end

end
