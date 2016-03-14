require 'rails_helper'

describe 'Global nav' do

  # TODO: fix failing specs

  # context 'when user is super_admin' do
  #   it 'should display users and settings link' do
  #     super_admin_login
  #     get fae_path

  #     nav_items = assigns[:fae_sidenav_items]
  #     expect(nav_items.last[:text]).to eq('Admin')
  #     nav_items.last[:sublinks].each do |sublink|
  #       expect(sublink[:text]).to match /Users|Root Settings|Activity Log/
  #     end
  #   end

  #   it 'should display nav_items from concern' do
  #     super_admin_login
  #     get fae_path

  #     nav_items = assigns[:fae_sidenav_items]
  #     expect(nav_items.second[:text]).to eq('Wines')
  #   end
  # end

  # context 'when user is admin' do
  #   it 'should display users' do
  #     admin_login
  #     get fae_path

  #     nav_items = assigns[:fae_sidenav_items]
  #     expect(nav_items.map{ |n| n[:text] }).to include('Users')
  #   end
  # end

  # context 'when user is user role' do
  #   it 'should display users' do
  #     user_login
  #     get fae_path

  #     nav_items = assigns[:fae_sidenav_items]
  #     expect(nav_items.last[:text]).to_not match /Users|Admin/
  #   end
  # end

end