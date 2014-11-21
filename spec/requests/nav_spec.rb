require 'rails_helper'

describe 'Global nav' do

  context 'when user is super_admin' do
    it 'should display users and settings link' do
      super_admin_login
      get fae_path

      nav_items = assigns[:fae_nav_items]
      expect(nav_items.last[:text]).to eq('Admin')
      nav_items.last[:sublinks].each do |sublink|
        expect(sublink[:text]).to match /Users|Root Settings/
      end
    end
  end

  context 'when user is admin' do
    it 'should display users' do
      admin_login
      get fae_path

      nav_items = assigns[:fae_nav_items]
      expect(nav_items.last[:text]).to eq('Users')
      expect(nav_items.last[:sublinks]).to be_nil
    end
  end

  context 'when user is user role' do
    it 'should display users' do
      user_login
      get fae_path

      nav_items = assigns[:fae_nav_items]
      expect(nav_items.last[:text]).to_not match /Users|Admin/
    end
  end

end