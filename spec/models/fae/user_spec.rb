require 'rails_helper'

describe Fae::User do

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role_id) }
  it { should validate_confirmation_of(:password).with_message('does not match Password') }

  describe '#public_users' do
    it 'should assign public users' do
      super_admin = FactoryGirl.create(:fae_role, name: 'super admin')
      admin = FactoryGirl.create(:fae_role, name: 'admin')
      user = FactoryGirl.create(:fae_role, name: 'user')
      super_user = FactoryGirl.create(:fae_user, first_name: 'Andy', role: super_admin)
      admin_user = FactoryGirl.create(:fae_user, first_name: 'Barbara', role: admin)
      user_user = FactoryGirl.create(:fae_user, first_name: 'Cory', role: user)

      expect(Fae::User.public_users).to eq([admin_user, user_user])
    end
  end

  describe '.super_admin?' do
    it 'should return true when user is a super admin' do
      super_admin = Fae::Role.new(name: 'super admin')
      super_user = Fae::User.new(role: super_admin)

      expect(super_user.super_admin?).to eq(true)
    end

    it 'should return false when user is not a super admin' do
      admin = Fae::Role.new(name: 'admin')
      user = Fae::User.new(role: admin)

      expect(user.super_admin?).to eq(false)
    end
  end

  describe '.admin?' do
    it 'should return true when user is a super admin' do
      super_admin = Fae::Role.new(name: 'super admin')
      super_user = Fae::User.new(role: super_admin)

      expect(super_user.admin?).to eq(false)
    end

    it 'should return false when user is not a super admin' do
      admin = Fae::Role.new(name: 'admin')
      user = Fae::User.new(role: admin)

      expect(user.admin?).to eq(true)
    end
  end

  describe '.user?' do
    it 'should return true when user is a user' do
      user_role = Fae::Role.new(name: 'user')
      user = Fae::User.new(role: user_role)

      expect(user.user?).to eq(true)
    end

    it 'should return false when user is not a user' do
      admin_role = Fae::Role.new(name: 'admin')
      user = Fae::User.new(role: admin_role)

      expect(user.user?).to eq(false)
    end
  end

  describe '.super_admin_or_admin?' do
    it 'should return true when user is a super admin' do
      user_role = Fae::Role.new(name: 'super admin')
      user = Fae::User.new(role: user_role)
      expect(user.super_admin_or_admin?).to eq(true)
    end

    it 'should return true when user is a admin' do
      user_role = Fae::Role.new(name: 'admin')
      user = Fae::User.new(role: user_role)

      expect(user.super_admin_or_admin?).to eq(true)
    end

    it 'should return false when user is a user' do
      admin_role = Fae::Role.new(name: 'user')
      user = Fae::User.new(role: admin_role)

      expect(user.super_admin_or_admin?).to eq(false)
    end
  end

  describe '.full_name' do
    it 'should return full name' do
      user = Fae::User.new(first_name: 'John', last_name: 'Doe')

      expect(user.full_name).to eq('John Doe')
    end
  end

  describe 'concerns' do
    it 'should allow instance methods through Fae::UserConcern' do
      user = Fae::User.new

      expect(user.instance_says_what).to eq('Fae::User instance: what?')
    end

    it 'should allow class methods through Fae::UserConcern' do
      expect(Fae::User.class_says_what).to eq('Fae::User class: what?')
    end
  end

end