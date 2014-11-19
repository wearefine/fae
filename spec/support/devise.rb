RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end

def super_admin_login
  super_admin_role = FactoryGirl.create(:fae_role, name: 'super admin')
  user = FactoryGirl.create(:fae_user, first_name: 'SuperAdmin', role: super_admin_role)

  post_via_redirect fae.user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
end