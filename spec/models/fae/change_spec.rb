require 'rails_helper'

describe Fae::Change do

  describe '#unique_changeable_types' do
    it 'should collect all unique models and order them' do
      release = FactoryBot.create(:release)
      FactoryBot.create(:cat)
      FactoryBot.create(:team)
      FactoryBot.create(:fae_user)
      release.update_attributes(name: 'something')

      expect(Fae::Change.unique_changeable_types).to eq([['Cat','Cat'], ['User','Fae::User'], ['Release','Release'], ['Team','Team'], ['Wine','Wine']])
    end
  end

end