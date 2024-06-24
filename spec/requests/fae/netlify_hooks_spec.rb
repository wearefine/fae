require 'rails_helper'

describe 'netlify_hooks#netlify_hook' do

  let!(:user1) { create(:fae_user, receive_deploy_notifications: true) }
  
  context 'testing controller action' do
    it 'should work' do
      post fae.netlify_hook_path

      expect(response.status).to eq(200)
    end
  end

end
