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

    belongs_to :imageable, polymorphic: true, touch: true

    def readonly?
      false
    end

    private

    def recreate_versions
      asset.recreate_versions! if Fae.recreate_versions && asset.present?
    end

  end
end
