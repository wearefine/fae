module Fae
  class NetlifyHooksController < ActionController::Base

    def netlify_hook
      unless Rails.env.test?
        signature = request.headers["X-Webhook-Signature"]
        if signature.blank?
          Rails.logger.info 'request.headers["X-Webhook-Signature"] header is missing'
          return head :forbidden
        end
        if Fae.netlify[:notification_hook_signature].blank?
          Rails.logger.info "Fae.netlify[:notification_hook_signature] is not set"
          return head :forbidden
        end

        options = {iss: "netlify", verify_iss: true, algorithm: "HS256"}
        decoded = JWT.decode(signature, Fae.netlify[:notification_hook_signature], true, options)
        unless decoded.first['sha256'] == Digest::SHA256.hexdigest(request.body.read)
          Rails.logger.info "Netlify hook signature mismatch, check the value of Fae.netlify[:notification_hook_signature] against the value of the JWS secret token in the Netlify webhook settings."
          return head :forbidden
        end
      end

      DeployNotifications.notify_admins(request).deliver_now
      return head :ok
    end
  end
end
