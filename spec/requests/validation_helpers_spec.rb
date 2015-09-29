require 'rails_helper'

describe 'validation_testers#new' do

  ### REGEX HELPERS ###
  context 'when using slug regex helpers' do

    it 'should not throw error' do
      admin_login
      get new_validation_testers_path
      FactoryGirl.create(:validation_tester, slug: 'validation-tester-1')

      expect(response.status).to eq(200)
    end

    # it 'should throw error' do
    #   admin_login
    #   get new_validation_testers_path

    # end

  end

  context 'when using email regex helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using url regex helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using phone regex helpers' do

    it 'should not throw error' do
    end

    it 'should throw error' do
    end

  end

  context 'when using zip regex helpers' do

    it 'valid zip should not throw error' do
    end

    it 'zip with bad format should throw error' do
    end

  end

  context 'when using youtube regex helpers' do

    it 'valid youtube id should not throw error' do
    end

    it 'youtube id with bad format should throw error' do
    end

  end

  # context 'when using hash helpers' do
  #   it 'valid slug should not throw error' do
  #   end

  #   it 'slug with bad format should throw error' do
  #   end

  #   it 'valid email should not throw error' do
  #   end

  #   it 'email with bad format should throw error' do
  #   end

  #   it 'valid url should not throw error' do
  #   end

  #   it 'url with bad format should throw error' do
  #   end

  #   it 'valid phone should not throw error' do
  #   end

  #   it 'phone with bad format should throw error' do
  #   end

  #   it 'valid zip should not throw error' do
  #   end

  #   it 'zip with bad format should throw error' do
  #   end

  #   it 'valid youtube id should not throw error' do
  #   end

  #   it 'youtube id with bad format should throw error' do
  #   end
  # end

end