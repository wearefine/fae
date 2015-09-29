require 'rails_helper'

describe 'validation_testers#new' do

  ### REGEX HELPERS ###
  context 'when using slug regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, slug: 'validation-tester-1')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, slug: 'validation-tester 2')

      test.should_not be_valid
    end

  end

  context 'when using email regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, email: 'test@testsite.com')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, email: 'testemail @gmail.com')

      test.should_not be_valid
    end

  end

  context 'when using url regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, url: 'http://poop.bike/')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, url: 'poop.bike')

      test.should_not be_valid
    end

  end

  context 'when using phone regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, phone: '800 588 2300')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, phone: '800 588 2300 Empire!')

      test.should_not be_valid
    end

  end

  context 'when using zip regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, zip: '97214')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, zip: 'apple pie')

      test.should_not be_valid
    end

  end

  context 'when using youtube regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, youtube_url: 'ZwBRX_h3U1U')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, youtube_url: '1cat')

      test.should_not be_valid
    end

  end

  context 'when using slug hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using email hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using url hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using phone hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using phone hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using youtube hash helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

end