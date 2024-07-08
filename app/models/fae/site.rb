module Fae
  class Site < ApplicationRecord
    include Fae::BaseModelConcern

    has_many :deploy_hooks, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :netlify_site, :netlify_site_id, presence: true

    def fae_display_field
      name
    end
  end
end