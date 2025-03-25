module Fae
  class SiteDeployHook < ApplicationRecord
    include Fae::BaseModelConcern
  
    belongs_to :site, class_name: 'Fae::Site'

    acts_as_list add_new_at: :top, scope: :site
    default_scope { order(:position) }

    validates :url, :environment, presence: true

    def fae_nested_parent
      :site
    end
  
  end  
end