module Fae
  class User < ActiveRecord::Base
    include Fae::BaseModelConcern
    include Fae::UserConcern

    after_save :turn_off_mfa, if: :saved_change_to_user_mfa_enabled?

    # Include default devise modules. Others available are:
    # :registerable, :confirmable, :timeoutable and :omniauthable
    devise :recoverable, :rememberable, :trackable, :lockable

    devise :two_factor_authenticatable, :two_factor_backupable,
      otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
      :otp_secret_encryption_key => ENV['OTP_SECRET_KEY']

    belongs_to :role

    validates :first_name, presence: true
    validates :email,
      presence: true,
      uniqueness: { message: 'That email address is already in use. Give another one a go.' },
      format: {
        with: Fae.validation_helpers.email_regex,
        message: 'is invalid'
      }
    validates :password,
      presence: { on: :create },
      confirmation: { message: "does not match Password"},
      length: { minimum: 8, allow_blank: true }
    validates :role_id, presence: true

    default_scope { order(:first_name, :last_name) }

    scope :public_users, -> { joins(:role).where.not('fae_roles.name = ?', 'super admin') }
    scope :live_super_admins, -> { joins(:role).where(active: true, fae_roles: { name: 'super admin' }) }

    def super_admin?
      role.name == 'super admin'
    end

    def admin?
      role.name == 'admin'
    end

    def user?
      role.name == 'user'
    end

    def super_admin_or_admin?
      super_admin? || admin?
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    # Called by Devise to see if an user can currently be signed in
    def active_for_authentication?
      active? && super
    end

    # Called by Devise to get the proper error message when an user cannot be signed in
    def inactive_message
      !active? ? :inactive : super
    end

    def fae_tracker_blacklist
      [:reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at]
    end

    # Generate an OTP secret it it does not already exist
    def generate_two_factor_secret_if_missing!
      return unless otp_secret.nil?
      update!(otp_secret: User.generate_otp_secret)
    end

    # Ensure that the user is prompted for their OTP when they login
    def enable_two_factor!
      update!(
        otp_required_for_login: true,
        user_mfa_enabled: true
      )
    end

    # Disable the use of OTP-based two-factor.
    def disable_two_factor!
      update!(
          user_mfa_enabled: false,
          otp_required_for_login: false,
          otp_secret: nil,
          otp_backup_codes: nil
        )
    end

    # Fully disables mfa on change to false
    def turn_off_mfa
      unless user_mfa_enabled
        update!(
          otp_required_for_login: false,
          otp_secret: nil,
          otp_backup_codes: nil
        )
      end
    end

    # URI for OTP two-factor QR code
    def two_factor_qr_code_uri
      issuer = ENV['OTP_2FA_ISSUER_NAME']
      label = [issuer, email].join(':')

      otp_provisioning_uri(label, issuer: issuer)
    end

    # Determine if backup codes have been generated
    def two_factor_backup_codes_generated?
      otp_backup_codes.present?
    end

    class << self

      def update_mfa(enabled)
        if enabled == '1'
          update(user_mfa_enabled: true)
        elsif enabled == '0'
          update(otp_required_for_login: false, user_mfa_enabled: false)
        end
      end

    end

  end
end
