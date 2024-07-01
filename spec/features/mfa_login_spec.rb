require 'rails_helper'
require 'spec_helper'

feature 'User with OTP two factor enabled' do

  before :each do
    create_super_user

    # Tun on MFA
    option = Fae::Option.instance
    option.site_mfa_enabled = true
    option.save
  end

  scenario 'cannot login without unknown user' do
    visit fae.new_user_session_path
    fill_in 'user_email', with: 'someone@example.com'
    fill_in 'user_password', with: 'letmein'
    click_button 'Submit'

    expect(page).to have_content("You’ll need a user name, password and MFA code that works.")
    expect(page).to_not have_content('Welcome to Fae')
  end

  scenario 'cannot login without a valid OTP' do
    user = FactoryBot.create(:fae_user, :with_otp,
      email: 'test@test.com',
      password: 'passord1',
      password_confirmation: 'passord1',
      active: true
      )

    visit fae.new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'passord1'
    fill_in 'user_otp_attempt', with: 'invalid-otp'
    click_button 'Submit'

    expect(page).to have_content("You’ll need a user name, password and MFA code that works.")
    expect(page).to_not have_content('Welcome to Fae')
  end

  scenario 'can login when providing a valid OTP' do
    user = FactoryBot.create(:fae_user, :with_otp,
      email: 'test@test.com',
      password: 'passord1',
      password_confirmation: 'passord1',
      active: true
      )

    visit fae.new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'passord1'
    fill_in 'user_otp_attempt', with: user.current_otp
    click_button 'Submit'

    expect(current_path).to eq(fae.root_path)
    expect(page).to have_content("Welcome to Fae")
  end
end