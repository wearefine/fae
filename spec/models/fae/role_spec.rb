require 'rails_helper'

describe Fae::Role do

  describe 'default_scopt' do
    it 'should order by position' do
      role3 = FactoryGirl.create(:fae_role, position: 2)
      role1 = FactoryGirl.create(:fae_role, position: 0)
      role2 = FactoryGirl.create(:fae_role, position: 1)

      expect(Fae::Role.all).to eq([role1, role2, role3])
    end
  end

  describe '#public_roles' do
    it 'should return all roles not "super admin"' do
      super_admin = FactoryGirl.create(:fae_role, name: 'super admin', position: 0)
      admin = FactoryGirl.create(:fae_role, name: 'admin', position: 1)
      user = FactoryGirl.create(:fae_role, name: 'user', position: 2)

      expect(Fae::Role.public_roles).to eq([admin, user])
    end
  end

end