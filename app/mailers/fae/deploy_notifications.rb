module Fae
  class DeployNotifications < ActionMailer::Base
    default from: Fae.deploy_notifications_mailer_sender
    layout 'layouts/fae/mailer'

    def notify_admins(body = nil, additional_emails = [])
      Rails.logger.info 'Sending deploy notification'
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