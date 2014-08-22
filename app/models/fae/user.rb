module Fae
  class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :validatable

    belongs_to :role

    validates :email, presence: true
    # validates :role_id, presence: true
    # validates :password, format: { with: /(?=.*\d)(?=.*[a-zA-Z])/, message: 'requires at least one letter and one number' }

    default_scope { order(:first_name, :last_name) }

    def super_admin?
      role.id === 1
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
