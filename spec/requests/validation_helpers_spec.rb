require 'rails_helper'

describe 'validation_testers#new' do

  ### REGEX HELPERS ###
  context 'when using slug regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, slug: 'validation-tester-1', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, slug: 'validation-tester 2', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using email regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, email: 'test@testsite.com', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, email: 'testemail @gmail.com', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using url regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, url: 'http://poop.bike/', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, url: 'poop.bike', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using zip regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, zip: '97214', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, zip: 'apple pie', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using youtube regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, youtube_url: 'ZwBRX_h3U1U', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, youtube_url: '1cat', second_slug: 'second-slug')

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
      FactoryGirl.create(:validation_tester, second_email: 'email@test.com', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_email: 'email/email.com', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using url hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_url: 'http://poop.bike/', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_url: 'poop.bike', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using zip hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_zip: '97214', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_zip: '124!0', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

  context 'when using youtube hash helpers' do

    it 'should not throw error' do
      admin_login
      get new_admin_validation_tester_path
      FactoryGirl.create(:validation_tester, second_youtube_url: 'ZwBRX_h3U1U', second_slug: 'second-slug')

      expect(response.status).to eq(200)
    end

    it 'should throw error' do
      admin_login
      get new_admin_validation_tester_path
      test = FactoryGirl.build(:validation_tester, second_youtube_url: '1cat', second_slug: 'second-slug')

      test.should_not be_valid
    end

  end

end