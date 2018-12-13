require 'rails_helper'

describe 'setup#first_user' do

  context 'when there are no super admins' do
    before :each do
      FactoryGirl.create(:fae_role, name: 'super admin')
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

    it "shouldn't allow POSTs to first user" do
      # super_admin_login creates the first super admin
      super_admin_login

      # attempt to create a second super admin
      post fae.first_user_path, params: { user: {
        'first_name' => 'John',
        'email' => 'test2@test.com',
        'password' => 'password123',
        'password_confirmation' => 'password123'
      }}

      expect(response.status).to eq(401)
      expect(Fae::User.all.length).to eq(1)
    end
  end

end

describe 'setup#create_first_user' do

  it 'should redirect you to the dashboard after submission' do
    FactoryGirl.create(:fae_role, name: 'super admin')
    user_params = {
      first_name: 'Super',
      last_name: 'Admin',
      email: 'super@admin.com',
      password: 'password',
      password_confirmation: 'password'
    }

    post fae.first_user_path, params: { user: user_params }

    expect(response).to redirect_to(fae.root_path)
  end

end
