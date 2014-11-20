module Fae::CacheBuster
  extend ActiveSupport::Concern

  included do
    after_save :bust_cache
    after_destroy :bust_cache
  end

  def bust_cache
    if Rails.env.production?
      base_domain = 'https://www.kimptonhotels.com'
      use_https = true
      use_auth = true
    elsif Rails.env.remote_development?
      base_domain = 'https://dev.kimptonhotels.com'
      use_https = true
      use_auth = true
    elsif Rails.env.development?
      base_domain = 'http://localhost:3000'
      use_https = false
      use_auth = false
    else
      return
    end

    klass = self.class.name
    id = self.id

    if klass === 'Image'
      klass = self.imageable_type
      id = self.imageable_id
    end

    if use_https
      require "net/https"
    else
      require "net/http"
    end
    require "uri"

    uri = URI.parse("#{base_domain}/bust-cache/#{klass}/#{id}")

    http = Net::HTTP.new(uri.host, uri.port)
    if use_https
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth("kimpton", Rails.application.secrets.cache_password) if use_auth
    response = http.request(request)
  end

end