require 'spec_helper'

RSpec.describe Fae::DeployNotifications, type: :mailer do
  describe '#notify_admins' do
    let!(:user1) { create(:fae_user, receive_deploy_notifications: true) }
    let!(:user2) { create(:fae_user, receive_deploy_notifications: true) }
    let!(:user3) { create(:fae_user, receive_deploy_notifications: false) }
    let!(:additional_emails) { ['test@example.com', 'another@example.com'] }
    let!(:mail) { Fae::DeployNotifications.notify_admins('Test body', additional_emails) }

    it 'sends an email to all users with receive_deploy_notifications set to true' do
      expect(mail.to).to include(user1.email)
      expect(mail.to).to include(user2.email)
      expect(mail.to).not_to include(user3.email)
    end

    it 'includes additional email addresses in the recipients' do
      expect(mail.to).to include('test@example.com')
      expect(mail.to).to include('another@example.com')
    end

    it 'sets the subject correctly' do
      fae_options = Fae::Option.instance
      current_time_in_zone = Time.now.in_time_zone(fae_options.time_zone).strftime('%Y-%m-%d %l:%M %p')
      expected_subject = "#{fae_options.title} Deploy Notification #{current_time_in_zone}"
      expect(mail.subject).to eq(expected_subject)
    end
  end
end