module Fae
  module NannyAbilities
    extend ActiveSupport::Concern

    def self.access_map
      {
      #  'wines' => [2,3],
      #  'asset_manager/tiers' => [1,2,3]
      }
    end

  end
end
