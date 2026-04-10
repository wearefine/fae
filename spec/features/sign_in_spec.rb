require 'spec_helper'

feature 'Sign In' do

  before :each do
    create_super_user
  end

  def no_models_exist?
    ActiveRecord::Base.descendants.map.reject { |m| m.name['Fae::'] || !m.instance_methods.include?(:fae_display_field) || Fae.dashboard_exclusions.include?(m.name) }
  end

  scenario 'when user leaves out email', js: true do
    visit fae.new_user_session_path

    fill_in 'user_password', with: 'password'
    click_button 'Submit'

    # Check for flash-toast element with data-message attribute (exists before JS transforms it)
    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to_not have_content('Welcome')
  end

  scenario 'when user leaves out password', js: true do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    click_button 'Submit'

    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to_not have_content('Welcome')
  end

  scenario "when user doesn't exist", js: true do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'password'
    click_button 'Submit'

    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to_not have_content('Welcome')
  end

  before :each do
    role = FactoryBot.create(:fae_role, name: 'admin')
    @user = FactoryBot.create(:fae_user,
      email: 'test@test.com',
      password: 'passord1',
      password_confirmation: 'passord1',
      active: true
      )
  end

  scenario "when user isn't active", js: true do
    @user.update_attribute(:active, false)

    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'

    expect(page).to have_css('.flash-toast[data-message]', visible: :all)
    expect(page).to_not have_content('Welcome')
  end

  scenario "when user is active", js: true do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'

    expect(page).to have_content('WELCOME')
  end

  scenario "when user signs in for the first time", js: true do
    visit fae.new_user_session_path

    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: 'passord1'
    click_button 'Submit'
    if no_models_exist?
      expect(page).to have_content("WELCOME TO FAE")
    end
  end
end
