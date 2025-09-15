module Fae
  class DeployHook < ApplicationRecord
    include Fae::BaseModelConcern

    acts_as_list add_new_at: :top
    default_scope { order(:position) }

    validates :url, :environment, presence: true
  end
end