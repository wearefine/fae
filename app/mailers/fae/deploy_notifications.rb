module Fae
  class DeployNotifications < ActionMailer::Base
    default from: Fae.deploy_notifications_mailer_sender
    layout 'layouts/fae/mailer'

    def notify_admins(body = nil, additional_emails = [])
      body = test_body if Rails.env.test?

      # Don't notify if the deploy is a code push
      if body['commit_ref'].present?
        Rails.logger.info "#{body['context']} - #{body['id']} is a code push, skipping notification"
        Rails.logger.info "#{body['branch']} #{body['commit_ref']}: #{body['commit_message']}"
        return
      end

      @deploy = body
      recipients = Fae::User.where(receive_deploy_notifications: true).pluck(:email)
      recipients += additional_emails
      @fae_options = Fae::Option.instance
      current_time_in_zone = Time.now.in_time_zone(@fae_options.time_zone).strftime('%Y-%m-%d %l:%M %p')
      subject = "#{@fae_options.title} Deploy Notification #{current_time_in_zone}"
      mail(to: recipients, subject: subject)
    end

    def test_body
      '{
        "id": "1",
        "site_id": "site-id",
        "build_id": "65d9119124fc2a63d3409bd3",
        "state": "ready",
        "name": "nuxt3-pss-deployment-refactor",
        "url": "http://nuxt3-pss-deployment-refactor.netlify.app",
        "ssl_url": "https://nuxt3-pss-deployment-refactor.netlify.app",
        "admin_url": "https://app.netlify.com/sites/nuxt3-pss-deployment-refactor",
        "deploy_url": "http://dynamic-routes--nuxt3-pss-deployment-refactor.netlify.app",
        "deploy_ssl_url": "https://dynamic-routes--nuxt3-pss-deployment-refactor.netlify.app",
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
          "permalink": "https://65d9119124fc2a63d3409bd5--nuxt3-pss-deployment-refactor.netlify.app",
          "alias": "https://nuxt3-pss-deployment-refactor.netlify.app",
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
    end
  end
end