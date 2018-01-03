require 'file_size_validator'

module Fae
  class File < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::FileConcern
    include Fae::AssetsValidatable

    mount_uploader :asset, Fae::FileUploader

    if defined?(FileValidators)
      validates :asset,
      file_size: {
        less_than_or_equal_to: Fae.max_file_upload_size.megabytes.to_i
      }
    else
      validates :asset,
      file_size: {
        maximum: Fae.max_file_upload_size.megabytes.to_i
      }
    end


    belongs_to :fileable, polymorphic: true, touch: true

    def readonly?
      false
    end

  end
end
