require 'spec_helper'

feature 'Publish' do

  before(:each) do
    super_admin_login
    visit fae.publish_path
  end



end
