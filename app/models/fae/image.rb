require 'file_size_validator'

module Fae
  class Image < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::ImageConcern
    include Fae::AssetsValidatable
    include ActionView::Helpers::UrlHelper

    attr_accessor :redirect
    mount_uploader :asset, Fae::ImageUploader

    after_save :recreate_versions

    validates :asset,
      file_size: {
        maximum: Fae.max_image_upload_size.megabytes.to_i
      }

    belongs_to :imageable, polymorphic: true, touch: true, optional: true

    def readonly?
      false
    end

    def edit_link
      if imageable_type == 'Fae::StaticPage'
        return link_to("#{imageable.title} Page", Fae::Engine.routes.url_helpers.edit_content_block_path(imageable))
      end
    end

    private

    def recreate_versions
      asset.recreate_versions! if Fae.recreate_versions && asset.present?
    end

    class << self

      def for_fae_index
        # Workaround for current inability to save images in capybara tests.
        # For tests we need to get the image objects regardless of asset presence.
        if Rails.env.test?
          order(updated_at: :desc)
        else
          where('asset IS NOT NULL').order(updated_at: :desc)
        end
      end

      def filter(params)
        conditions = {}
        if params['parent_model'].present?
          if params['parent_model'].include?('-')
            parent_model, parent_id = params['parent_model'].split('-')
            conditions[:imageable_type] = parent_model
            conditions[:imageable_id] = parent_id
          else
            conditions[:imageable_type] = params['parent_model']
          end
        end
        conditions[:attached_as] = params['attached_as'] if params['attached_as'].present?
        alt_text_conditions = []
        case params['alt_text_presence']
        when 'Present'
          alt_text_conditions = ['alt IN (?)', ['', nil]]
        when 'Missing'
          alt_text_conditions = ['alt NOT IN (?)', ['', nil]]
        end
        for_fae_index.where(conditions).where(alt_text_conditions)
      end

    end

  end
end
