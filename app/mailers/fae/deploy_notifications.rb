module Fae
  class DeployNotifications < ActionMailer::Base
    default from: Fae.deploy_notifications_mailer_sender
    layout 'layouts/fae/mailer'

    def notify_admins(body = nil, additional_emails = [])
      if body.blank?
        Rails.logger.info "DeployNotifications.notify_admins called without a body"
        return
      end
      body = JSON.parse(body)

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
  end
end