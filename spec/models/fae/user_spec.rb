require 'rails_helper'

describe Fae::User do

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }

  describe '#public_users' do
    it 'should assign public users' do
      super_admin = FactoryGirl.create(:fae_role, name: 'super admin')
      admin = FactoryGirl.create(:fae_role, name: 'admin')
      user = FactoryGirl.create(:fae_role, name: 'user')
      super_user = FactoryGirl.create(:fae_user, role: super_admin)
      admin_user = FactoryGirl.create(:fae_user, role: admin)
      user_user = FactoryGirl.create(:fae_user, role: user)

      expect(Fae::User.public_users).to eq([admin_user, user_user])
    end
  end

  describe '.super_admin?' do
    it 'should return true when user is a super admin' do
      super_admin = FactoryGirl.create(:fae_role, name: 'super admin')
      super_user = FactoryGirl.build(:fae_user, role: super_admin)

      expect(super_user.super_admin?).to eq(true)
    end

    it 'should return false when user is not a super admin' do
      admin = FactoryGirl.create(:fae_role, name: 'admin')
      user = FactoryGirl.build(:fae_user, role: admin)

      expect(user.super_admin?).to eq(false)
    end
  end

  describe '.admin?' do
    it 'should return true when user is a super admin' do
      super_admin = FactoryGirl.create(:fae_role, name: 'super admin')
      super_user = FactoryGirl.build(:fae_user, role: super_admin)

      expect(super_user.admin?).to eq(false)
    end

    it 'should return false when user is not a super admin' do
      admin = FactoryGirl.create(:fae_role, name: 'admin')
      user = FactoryGirl.build(:fae_user, role: admin)

      expect(user.admin?).to eq(true)
    end
  end

  describe '.full_name' do
    it 'should return full name' do
      user = FactoryGirl.build(:fae_user, first_name: 'John', last_name: 'Doe')

      expect(user.full_name).to eq('John Doe')
    end
  end

end