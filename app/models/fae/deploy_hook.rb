module Fae
  class DeployHook < ApplicationRecord
    include Fae::BaseModelConcern

    default_scope { order(:environment) }

    validates :url, :environment, presence: true
  end
end