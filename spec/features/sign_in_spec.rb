require 'spec_helper'

feature 'Sign In' do

  before :each do
    create_super_user
  end

  def no_models_exist?
    ActiveRecord::Base.descendants.map.reject { |m| m.name['Fae::'] || !m.instance_methods.include?(:fae_display_field) || Fae.dashboard_exclusions.include?(m.name) }
  end

  scenario 'when user leaves out email' do
    visit fae.new_user_session_path

    fill_in 'user_password', with: 'password'
    click_button 'Submit'

    expect(page).to have_content('You’ll need a user name and a password that works.')
    expect(page).to_not have_content('Welcome')
  end

  scenario 'when user leaves out password' do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    click_button 'Submit'

    expect(page).to have_content('You’ll need a user name and a password that works.')
    expect(page).to_not have_content('Welcome')
  end

  scenario "when user doesn't exist" do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'password'
    click_button 'Submit'

    expect(page).to have_content('You’ll need a user name and a password that works.')
    expect(page).to_not have_content('Welcome')
  end

  before :each do
    role = FactoryGirl.create(:fae_role, name: 'admin')
    @user = FactoryGirl.create(:fae_user,
      email: 'test@test.com',
      password: 'passord1',
      password_confirmation: 'passord1',
      active: true
      )
  end

  scenario "when user isn't active" do
    @user.update_attribute(:active, false)

    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'

    expect(page).to have_content('Your account is not activated yet.')
    expect(page).to_not have_content('Welcome')
  end

  scenario "when user is active" do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'

    expect(page).to have_content('Welcome')
  end

  scenario "when user signs in for the first time" do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'
    if no_models_exist?
      expect(page).to have_content("Let's get started!")
    end
  end
end
