module Devise
  module Models
    module TwoFactorBackupable

      def invalidate_otp_backup_code!(code)
        codes = self.otp_backup_codes || []

        if codes.is_a? String 
          codes = JSON.parse(codes)
        end

        codes.each do |backup_code|
          next unless Devise::Encryptor.compare(self.class, backup_code, code)

          codes.delete(backup_code)
          self.otp_backup_codes = codes
          return true
        end

        false
      end

    end
  end
end