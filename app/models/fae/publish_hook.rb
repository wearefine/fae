module Fae
  class PublishHook < ApplicationRecord
    include Fae::BaseModelConcern

    default_scope { order(:environment) }

    validates :url, :environment, presence: true
  end
end
