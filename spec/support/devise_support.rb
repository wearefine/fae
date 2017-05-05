def super_admin_login
  user = create_super_user

  login(user)
end

def admin_login
  create_super_user

  role = FactoryGirl.create(:fae_role, name: 'admin')
  user = FactoryGirl.create(:fae_user, first_name: 'Admin', role: role)

  login(user)
end

def user_login
  create_super_user

  role = FactoryGirl.create(:fae_role, name: 'user')
  user = FactoryGirl.create(:fae_user, first_name: 'User', role: role)

  login(user)
end

# this method creates a super admin
# which is required for the admin to function properly
# without a super admin most pages will redirect to a fae.first_user_path
def create_super_user
  role = FactoryGirl.create(:fae_role, name: 'super admin')
  FactoryGirl.create(:fae_user, first_name: 'SuperAdmin', role: role)
end

module SignInControllerHelper
  def login(user)
    sign_in user
  end
end

module SignInRequestHelper
  def login(user)
    if Rails::VERSION::MAJOR > 4
      post fae.user_session_path, params: { user: { 'email' => user.email, 'password' => user.password } }

      follow_redirect!
    else
      post_via_redirect fae.user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
    end
  end
end

module SignInFeatureHelper
  def login(user)
    visit fae.new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Submit'
    user
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include SignInControllerHelper, type: :controller
  config.include SignInRequestHelper, type: :request
  config.include SignInFeatureHelper, type: :feature
end
