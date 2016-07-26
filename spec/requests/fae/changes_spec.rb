require 'rails_helper'

describe 'before_filter' do

  it 'should update Fae::Change.current_user with current_user' do
    user = create_super_user
    if Rails::VERSION::MAJOR > 4
      post fae.user_session_path, params: { user: { 'email' => user.email, 'password' => user.password } }
    else
      post_via_redirect fae.user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
    end

    get fae.root_path

    expect(Fae::Change.current_user).to eq(user.id)
  end

end