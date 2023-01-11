module Fae
  class Deploy < ApplicationRecord
    include Fae::BaseModelConcern

    belongs_to :user
  end
end
