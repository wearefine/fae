require 'rails_helper'

describe Fae::NetlifyApi, type: :model do

  describe '#last_successful_any_deploy' do
    it 'should return the last successful deploy' do
      expect(Fae::NetlifyApi.new().last_successful_any_deploy['title']).to eq('Staging complete')
    end
  end

  describe '#last_successful_production_deploy' do
    it 'should return the last successful production deploy' do
      expect(Fae::NetlifyApi.new().last_successful_production_deploy['title']).to eq('A production build')
    end
  end

  describe '#last_successful_staging_deploy' do
    it 'should return the last successful staging deploy' do
      expect(Fae::NetlifyApi.new().last_successful_staging_deploy['title']).to eq('Staging complete')
    end
  end

end
