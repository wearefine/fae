require 'file_size_validator'

module Fae
  class Image < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::ImageConcern
    include Fae::AssetsValidatable

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

    private

    def recreate_versions
      asset.recreate_versions! if Fae.recreate_versions && asset.present?
    end

    class << self

      def for_fae_index
        where('asset IS NOT NULL').order(updated_at: :desc)
      end

      def filter(params)
        conditions = {}
        conditions[:imageable_type] = params['parent_model'] if params['parent_model'].present?
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
