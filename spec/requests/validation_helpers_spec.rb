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
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_slug: 'second slug')

      test.should_not be_valid
    end

  end

  context 'when using email hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_email: 'email@test.com')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_email: 'email/email.com')

      test.should_not be_valid
    end

  end

  context 'when using unique email hash helpers' do

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, unique_email: 'email@test.com')
      test = FactoryGirl.build(:validation_tester, unique_email: 'email@test.com')

      test.should_not be_valid
    end

  end

  context 'when using url hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_url: 'http://poop.bike/')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_url: 'poop.bike')

      test.should_not be_valid
    end

  end

  context 'when using phone hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_phone: '800 588 2300')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_phone: '800 588 2300 Empire, today!')

      test.should_not be_valid
    end

  end

  context 'when using zip hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_zip: '97214')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_zip: '124!0')

      test.should_not be_valid
    end

  end

  context 'when using youtube hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_youtube_url: 'ZwBRX_h3U1U')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_youtube_url: '1cat')

      test.should_not be_valid
    end

  end

end