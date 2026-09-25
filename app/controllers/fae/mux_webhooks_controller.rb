module Fae
  # Public endpoint for Mux webhooks, so it skips Fae's session auth and CSRF and verifies the Mux signature instead.
  class MuxWebhooksController < ActionController::API
    SIGNATURE_TOLERANCE = 5.minutes.to_i

    before_action :verify_mux_signature!

    def create
      # Change tracking is thread-local and would otherwise credit whichever admin last used this thread.
      Fae::Change.current_user = nil
      Fae::Video.process_mux_event(JSON.parse(request.raw_post))
      head :ok
    rescue JSON::ParserError
      head :bad_request
    end

    private

    # https://www.mux.com/docs/core/verify-webhook-signatures
    def verify_mux_signature!
      head :unauthorized unless valid_mux_signature?
    end

    def valid_mux_signature?
      secret = ENV['MUX_WEBHOOK_SECRET']
      header = request.headers['Mux-Signature']
      return false if secret.blank? || header.blank?

      parts = header.split(',').map { |part| part.strip.split('=', 2) }
      timestamp = parts.find { |key, _| key == 't' }.try(:last)
      signatures = parts.select { |key, _| key == 'v1' }.map(&:last)
      return false if timestamp.blank? || signatures.empty?
      return false if (Time.now.to_i - timestamp.to_i).abs > SIGNATURE_TOLERANCE

      expected = OpenSSL::HMAC.hexdigest('SHA256', secret, "#{timestamp}.#{request.raw_post}")
      signatures.any? { |signature| Rack::Utils.secure_compare(signature.to_s, expected) }
    end

  end
end
