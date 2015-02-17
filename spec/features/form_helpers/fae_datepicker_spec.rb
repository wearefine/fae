require 'spec_helper'

feature 'fae_datepicker' do

  scenario 'should open and select date', js: true do
    admin_login
    visit new_admin_release_path

    release_date_input = page.find('#release_release_date')
    release_date_input.click
    within('.ui-datepicker-calendar') do
      click_link('10')
    end

    today = Date.today
    expect(release_date_input.value).to eq("#{today.strftime('%b')} 10, #{today.year}")
  end

end
