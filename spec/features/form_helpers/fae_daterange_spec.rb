require 'spec_helper'

feature 'fae_daterange' do

  scenario 'should open and select dates', js: true do
    admin_login
    visit new_admin_release_path

    start_date_input = page.find('#release_show')
    end_date_input = page.find('#release_hide')
    start_date_input.click
    within('.date-picker-wrapper .month1') do
      find('div.day', text: '10').click
      find('div.day', text: '15').click
    end

    expect(start_date_input.value).to include('10')
    expect(end_date_input.value).to include('15')
  end

end
