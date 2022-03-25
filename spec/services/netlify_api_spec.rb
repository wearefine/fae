require 'rails_helper'

describe Fae::NetlifyApi, type: :model do

  describe '#get_deploys' do
    it 'should return deploys' do
      expect(Fae::NetlifyApi.new().get_deploys).not_to be_nil
    end
  end

end
