require 'file_size_validator' 

module Fae
  class File < ActiveRecord::Base

    include Fae::FileConcern
    include Fae::AssetsValidatable

    mount_uploader :asset, Fae::FileUploader

    validates :asset,
      file_size: {
        maximum: Fae.max_file_upload_size.megabytes.to_i
      }

    belongs_to :fileable, polymorphic: true, touch: true

  end
end
