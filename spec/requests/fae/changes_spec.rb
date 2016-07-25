require 'rails_helper'

describe 'before_filter' do

  it 'should update Fae::Change.current_user with current_user' do
    user = create_super_user
    post fae.user_session_path, params: { user: { 'email' => user.email, 'password' => user.password } }
    follow_redirect!
    get fae.root_path

    expect(Fae::Change.current_user).to eq(user.id)
  end

end