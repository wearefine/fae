require 'spec_helper'

RSpec.describe Fae::DeployNotifications, type: :mailer do
  describe '#notify_admins' do
    let!(:user1) { create(:fae_user, receive_deploy_notifications: true) }
    let!(:user2) { create(:fae_user, receive_deploy_notifications: true) }
    let!(:user3) { create(:fae_user, receive_deploy_notifications: false) }
    let!(:additional_emails) { ['test@example.com', 'another@example.com'] }
    let!(:success_mail) { Fae::DeployNotifications.notify_admins(TEST_SUCCESS, additional_emails) }
    let!(:failure_mail) { Fae::DeployNotifications.notify_admins(TEST_FAILURE, additional_emails) }

    it 'sends an email to all users with receive_deploy_notifications set to true' do
      expect(success_mail.to).to include(user1.email)
      expect(success_mail.to).to include(user2.email)
      expect(success_mail.to).not_to include(user3.email)
    end

    it 'includes additional email addresses in the recipients' do
      expect(success_mail.to).to include('test@example.com')
      expect(success_mail.to).to include('another@example.com')
    end

    it 'sets the subject correctly' do
      fae_options = Fae::Option.instance
      current_time_in_zone = Time.now.in_time_zone(fae_options.time_zone).strftime('%Y-%m-%d %l:%M %p')
      expected_subject = "#{fae_options.title} Deploy Notification #{current_time_in_zone}"
      expect(success_mail.subject).to eq(expected_subject)
    end

    it 'sets the status correctly' do
      expect(success_mail.body.encoded).to include('The deploy was successful.')
      expect(failure_mail.body.encoded).to include('An error occurred.')
    end
  end
end

TEST_SUCCESS = '{
    "id": "1",
    "site_id": "site-id",
    "build_id": "65d9119124fc2a63d3409bd3",
    "state": "ready",
    "name": "test-name",
    "url": "",
    "ssl_url": "",
    "admin_url": "",
    "deploy_url": "",
    "deploy_ssl_url": "",
    "created_at": "2024-02-23T21:43:45.155Z",
    "updated_at": "2024-02-23T21:44:58.549Z",
    "user_id": "user-id",
    "error_message": null,
    "required": [
  
    ],
    "required_functions": [
  
    ],
    "commit_ref": null,
    "review_id": null,
    "branch": "dynamic-routes",
    "commit_url": null,
    "skipped": null,
    "locked": null,
    "title": null,
    "commit_message": null,
    "review_url": null,
    "published_at": "2024-02-23T21:44:58.502Z",
    "context": "production",
    "deploy_time": 58,
    "available_functions": [
      {
        "n": "hello",
        "d": "907d81533efca59bfc94a1cb3b870afaa20754920ddbb00b82294e397cef4f6c",
        "dn": null,
        "g": null,
        "bd": {
          "runtimeAPIVersion": 1
        },
        "p": 10,
        "id": "9ad116795fbd106689f2023583e8f15232d95fe55180bdf4a13f7ea262edf026",
        "a": "333468350809",
        "c": "2024-02-15T20:56:15.202Z",
        "oid": "bba4aa2c5c8e9be4632a4b84f04efb456af0967038dab2f26002cc97a8aac7bf",
        "r": "nodejs20.x",
        "rg": "us-west-2",
        "s": 85686
      },
      {
        "n": "portfolio",
        "d": "0a5813f4d53ecb8384ed64287c98bf0f11cbe0756a49b6f3dbb7871194c14724",
        "dn": null,
        "g": null,
        "bd": {
          "runtimeAPIVersion": 1
        },
        "p": 10,
        "id": "4903b0c6a9112063b0403ee9c77d584113fa89001cd116e264e3dd35a8a12602",
        "a": "632907006241",
        "c": "2024-02-15T20:56:15.063Z",
        "oid": "277ae21b806d41184c495cb828c5ad3c12dce43fa4d97badda1be126651aeaf9",
        "r": "nodejs20.x",
        "rg": "us-west-2",
        "s": 86051
      }
    ],
    "screenshot_url": null,
    "committer": null,
    "skipped_log": null,
    "manual_deploy": false,
    "file_tracking_optimization": true,
    "plugin_state": "none",
    "lighthouse_plugin_scores": null,
    "links": {
      "permalink": "",
      "alias": "",
      "branch": null
    },
    "framework": "nuxt",
    "entry_path": null,
    "views_count": null,
    "function_schedules": [
  
    ],
    "public_repo": false,
    "pending_review_reason": null,
    "lighthouse": null,
    "edge_functions_present": true,
    "expires_at": null
}'

TEST_FAILURE = '{
    "id": "1",
    "site_id": "site-id",
    "build_id": "65d9119124fc2a63d3409bd3",
    "state": "error",
    "name": "test-name",
    "url": "",
    "ssl_url": "",
    "admin_url": "",
    "deploy_url": "",
    "deploy_ssl_url": "",
    "created_at": "2024-02-23T21:43:45.155Z",
    "updated_at": "2024-02-23T21:44:58.549Z",
    "user_id": "user-id",
    "error_message": null,
    "required": [
  
    ],
    "required_functions": [
  
    ],
    "commit_ref": null,
    "review_id": null,
    "branch": "dynamic-routes",
    "commit_url": null,
    "skipped": null,
    "locked": null,
    "title": null,
    "commit_message": null,
    "review_url": null,
    "published_at": "2024-02-23T21:44:58.502Z",
    "context": "production",
    "deploy_time": 58,
    "available_functions": [
      {
        "n": "hello",
        "d": "907d81533efca59bfc94a1cb3b870afaa20754920ddbb00b82294e397cef4f6c",
        "dn": null,
        "g": null,
        "bd": {
          "runtimeAPIVersion": 1
        },
        "p": 10,
        "id": "9ad116795fbd106689f2023583e8f15232d95fe55180bdf4a13f7ea262edf026",
        "a": "333468350809",
        "c": "2024-02-15T20:56:15.202Z",
        "oid": "bba4aa2c5c8e9be4632a4b84f04efb456af0967038dab2f26002cc97a8aac7bf",
        "r": "nodejs20.x",
        "rg": "us-west-2",
        "s": 85686
      },
      {
        "n": "portfolio",
        "d": "0a5813f4d53ecb8384ed64287c98bf0f11cbe0756a49b6f3dbb7871194c14724",
        "dn": null,
        "g": null,
        "bd": {
          "runtimeAPIVersion": 1
        },
        "p": 10,
        "id": "4903b0c6a9112063b0403ee9c77d584113fa89001cd116e264e3dd35a8a12602",
        "a": "632907006241",
        "c": "2024-02-15T20:56:15.063Z",
        "oid": "277ae21b806d41184c495cb828c5ad3c12dce43fa4d97badda1be126651aeaf9",
        "r": "nodejs20.x",
        "rg": "us-west-2",
        "s": 86051
      }
    ],
    "screenshot_url": null,
    "committer": null,
    "skipped_log": null,
    "manual_deploy": false,
    "file_tracking_optimization": true,
    "plugin_state": "none",
    "lighthouse_plugin_scores": null,
    "links": {
      "permalink": "",
      "alias": "",
      "branch": null
    },
    "framework": "nuxt",
    "entry_path": null,
    "views_count": null,
    "function_schedules": [
  
    ],
    "public_repo": false,
    "pending_review_reason": null,
    "lighthouse": null,
    "edge_functions_present": true,
    "expires_at": null
}'