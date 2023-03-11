module Fae
  class SeoSet < ActiveRecord::Base
    include Fae::BaseModelConcern
    include Fae::SeoSetConcern

    has_fae_image :social_media_image
    belongs_to :seo_setable, polymorphic: true, touch: true, optional: true

    def fae_display_field
      seo_title
    end

  end
end
