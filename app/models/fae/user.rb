module Fae
  class User < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::UserConcern

    # Include default devise modules. Others available are:
    # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable

    belongs_to :role

    validates :first_name, presence: true
    validates :email,
      presence: true,
      uniqueness: { message: 'That email address is already in use. Give another one a go.' },
      format: {
        with: /^\s*(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})[\s\/,;]*)+$/i,
        message: 'is invalid',
        multiline: true
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
  end
end
