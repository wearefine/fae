module Fae
  class Site < ApplicationRecord
    include Fae::BaseModelConcern

    default_scope { order(:name) }

    has_many :site_deploy_hooks, dependent: :destroy, class_name: 'Fae::SiteDeployHook'

    validates :name, presence: true, uniqueness: true
    validates :netlify_site, :netlify_site_id, presence: true

    def fae_display_field
      name
    end
  end
end