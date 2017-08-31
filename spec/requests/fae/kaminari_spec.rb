require 'rails_helper'

describe 'kaminari settings' do

  it 'should load from Fae initializer' do
    super_admin_login
    get fae_path

    expect(Kaminari.config.default_per_page).to eq(20)
  end

end
