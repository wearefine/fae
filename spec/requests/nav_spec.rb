require 'rails_helper'

describe 'Global nav' do

  context 'when user is super_admin' do
    it 'should display users, and settings link' do
      super_admin_login
      get fae_path

      expect(response.body).to include('<a href="/admin/users">Users</a>')
      expect(response.body).to include('<a href="/admin/activity">Activity Log</a>')
      expect(response.body).to include('<a href="/admin/root">Root Settings</a>')
    end

    it 'should display events top nav item' do
      super_admin_login
      get fae_path

      expect(response.body).to include('<a href="#">Events</a>')
    end
  end

  context 'when user is admin' do
    it 'should display users, deploy and user activity' do
      admin_login
      get fae_path

      expect(response.body).to include('<a href="/admin/users">Users</a>')
      expect(response.body).to include('<a href="/admin/activity">Activity Log</a>')
      expect(response.body).to include('<a href="/admin/deploy">Deployments</a>')
    end

    it 'should not display root settings' do
      admin_login
      get fae_path

      expect(response.body).to_not include('<a href="/admin/root">Root Settings</a>')
    end

    it 'should display events top nav item' do
      admin_login
      get fae_path

      expect(response.body).to include('<a href="#">Events</a>')
    end
  end

  context 'when user is user role' do
    it 'should not display users or settings links' do
      user_login
      get fae_path

      expect(response.body).to_not include('<a href="/admin/users">Users</a>')
      expect(response.body).to_not include('<a href="/admin/activity">Activity Log</a>')
      expect(response.body).to_not include('<a href="/admin/root">Root Settings</a>')
    end

    it 'should not display beers top nav item' do
      user_login
      get fae_path

      expect(response.body).to_not include('<a href="#">Beers</a>')
    end
  end

end