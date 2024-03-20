require 'slack-notifier'

module Fae
  class SlackNotification

    def send_slack(webhook: ENV["SLACK_WEBHOOK_URL"], message: nil)
      if webhook.is_a?(String)
        webhook = webhook.split(',')
      end
      webhook.each do |wh|
        notifier = Slack::Notifier.new wh
        notifier.ping message
      end
    end

  end
end