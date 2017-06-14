module Fae
  class Role < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::RoleConcern

    has_many :users

    acts_as_list add_new_at: :bottom
    default_scope { order('-position DESC') }

    scope :public_roles, -> {where.not(name: 'super admin')}

    def fae_tracker_blacklist
      'all'
    end
  end
end
