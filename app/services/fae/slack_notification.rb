require 'slack-notifier'

module Fae
  class SlackNotification

    def send_slack(webhook: Fae.slack_webhook_url, message: nil)
      if webhook.is_a?(String)
        webhook = webhook.split(',')
      end
      webhook.each do |wh|
        notifier = Slack::Notifier.new wh
        notifier.ping message
      end if webhook.present?
    end

  end
end