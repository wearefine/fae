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

  let!(:user) do
    FactoryBot.create(:fae_user, :with_otp,
      email: 'test@test.com',
      password: 'passord1',
      password_confirmation: 'passord1',
      active: true
    )
  end

  def submit_credentials(email: user.email, password: 'passord1')
    visit fae.new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Submit'
  end

  scenario 'login form does not ask for the MFA code', js: true do
    visit fae.new_user_session_path

    expect(page).to have_field('user_email')
    expect(page).to have_field('user_password')
    expect(page).to_not have_field('user_otp_attempt')
  end

  scenario 'cannot login without unknown user', js: true do
    submit_credentials(email: 'someone@example.com', password: 'letmein')

    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to_not have_field('user_otp_attempt')
    expect(page).to_not have_content('WELCOME TO FAE')
  end

  scenario 'cannot login without a valid OTP', js: true do
    submit_credentials
    fill_in 'user_otp_attempt', with: 'invalid-otp'
    click_button 'Verify'

    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to have_field('user_otp_attempt')
    expect(page).to_not have_content('WELCOME TO FAE')
  end

  scenario 'can login when providing a valid OTP', js: true do
    submit_credentials
    expect(page).to have_field('user_otp_attempt')

    fill_in 'user_otp_attempt', with: user.current_otp
    click_button 'Verify'

    expect(current_path).to eq(fae.root_path)
    expect(page).to have_content("WELCOME TO FAE")
  end

  scenario 'can go back to the login form from the MFA step', js: true do
    submit_credentials
    click_link 'Back to Sign In'

    expect(page).to have_field('user_email')
    expect(page).to_not have_field('user_otp_attempt')
  end
end
