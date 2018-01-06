# encoding: utf-8
module Fae
  class FileUploader < CarrierWave::Uploader::Base

    # Include RMagick support:
    # include CarrierWave::RMagick

    process :save_file_size_in_model

    def save_file_size_in_model
      model.file_size = file.size
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    def extension_white_list
      %w(jpg jpeg gif png pdf)
    end

  end
end
