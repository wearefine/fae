require 'spec_helper'

feature 'fae_filter_select' do

  scenario 'collection options defaults to Class.for_fae_index' do
    FactoryGirl.create(:wine, name_en: 'Some Wine')
    FactoryGirl.create(:wine, name_en: 'Another Wine')

    admin_login
    visit admin_releases_path

    expect(page).to have_select('filter[wine]', with_options: ['Another Wine', 'Some Wine'])
  end

  scenario 'collection options are assignable' do
    FactoryGirl.create(:acclaim, score: 'Show Me')
    FactoryGirl.create(:acclaim, score: '')

    admin_login
    visit admin_releases_path

    expect(page).to have_select('filter[acclaims]', with_options: ['Show Me'])
  end

  scenario 'options are assignable' do
    admin_login
    visit admin_releases_path

    expect(page).to have_select('filter[test]', with_options: ['one', 'two'])
  end

end
