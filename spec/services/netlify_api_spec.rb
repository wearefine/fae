require 'rails_helper'

describe Fae::NetlifyApi, type: :model do

  describe '#get_finished_deploys' do
    it 'should return only complete deploys' do
      expect(Fae::NetlifyApi.new().get_deploys.pluck(:title)).to_not include('Staging building', 'Staging processing')
    end
  end

  describe '#get_current_deploy' do
    it 'should return the first running deploy' do
      expect(Fae::NetlifyApi.new().current_deploy['title']).to eq('Staging building')
    end
  end

  describe '#last_successful_any_deploy' do
    it 'should return the last successful deploy' do
      expect(Fae::NetlifyApi.new().last_successful_any_deploy['title']).to eq('Staging complete')
    end
  end

  describe '#last_successful_admin_deploy' do
    it 'should return the last successful deploy with no commit_ref' do
      expect(Fae::NetlifyApi.new().last_successful_admin_deploy['title']).to eq('Staging admin complete')
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
