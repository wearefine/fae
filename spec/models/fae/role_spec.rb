require 'rails_helper'

describe Fae::Role do

  describe 'default_scope' do
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

  describe 'concerns' do
    it 'should allow instance methods through Fae::RoleConcern' do
      role = Fae::Role.new

      expect(role.instance_says_what).to eq('Fae::Role instance: what?')
    end

    it 'should allow class methods through Fae::RoleConcern' do
      expect(Fae::Role.class_says_what).to eq('Fae::Role class: what?')
    end
  end

end