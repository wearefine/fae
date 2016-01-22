module Fae
  class ApiKey < ActiveRecord::Base

    establish_connection "#{Rails.env}".to_sym

    before_create :generate_access_token

    private

    def generate_access_token
      begin
        self.access_token = SecureRandom.hex
      end while self.class.exists?(access_token: access_token)
    end

  end
end