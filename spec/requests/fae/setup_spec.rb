require 'rails_helper'

describe 'setup#first_user' do

  context 'when there are no super admins' do
    FactoryGirl.create(:fae_role, name: 'super admin')
    it 'should redirect you to setup#first_user' do
      get fae.root_path

      expect(response).to redirect_to(fae.first_user_path)
    end

    it 'should respond successfully' do
      get fae.first_user_path

      expect(response.status).to eq(200)
    end
  end

  context 'when there are no active super admins' do
    before :each do
      role = FactoryGirl.create(:fae_role, name: 'super admin')
      FactoryGirl.create(:fae_user, first_name: 'SuperAdmin', role: role, active: false)
    end

    it 'should redirect you to setup#first_user' do
      get fae.root_path

      expect(response).to redirect_to(fae.first_user_path)
    end

    it 'should respond successfully' do
      get fae.first_user_path

      expect(response.status).to eq(200)
    end
  end

  context 'when there are super admins' do
    it 'should respond not found' do
      super_admin_login
      get fae.first_user_path

      expect(response.status).to eq(404)
    end
  end

end

describe 'setup#create_first_user' do

  it 'should redirect you to the dashboard after submission' do
    FactoryGirl.create(:fae_role, name: 'super admin')

    post fae.first_user_path,
      user: {
        first_name: 'Super',
        last_name: 'Admin',
        email: 'super@admin.com',
        password: 'password',
        password_confirmation: 'password'
      }

    expect(response).to redirect_to(fae.root_path)
  end

end
