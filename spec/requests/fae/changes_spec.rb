require 'rails_helper'

describe 'before_filter' do

  it 'should update Fae::Change.current_user with current_user' do
    expect(Fae::Change.current_user).to eq(nil)

    user = create_super_user
    post_via_redirect fae.user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
    get fae.root_path

    expect(Fae::Change.current_user).to eq(user.id)
  end

end