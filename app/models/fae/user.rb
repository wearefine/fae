module Fae
  class User < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::UserConcern

    # Include default devise modules. Others available are:
    # :registerable, :confirmable, :timeoutable and :omniauthable
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :lockable

    belongs_to :role

    validates :first_name, presence: true
    validates :email,
      presence: true,
      uniqueness: { 
        message: 'That email address is already in use. Give another one a go.', 
        case_sensitive: true 
      },
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
  end
end
