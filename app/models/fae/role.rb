module Fae
  class Role < ActiveRecord::Base
    has_many :users

    default_scope { order('-position DESC') }

    scope :public_roles, -> {where.not(name: 'super admin')}
  end
end
