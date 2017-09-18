require 'rails_helper'

describe 'devise settings' do

  it 'should load from Fae initializer' do
    super_admin_login
    get fae_path

    expect(Devise.secret_key).to_not eq(nil)
    expect(Devise.mailer_sender).to eq('test@test.com')
  end

end
