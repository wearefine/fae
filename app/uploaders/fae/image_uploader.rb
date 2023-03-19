# encoding: utf-8
module Fae
  class ImageUploader < CarrierWave::Uploader::Base

    include CarrierWave::MiniMagick

    # saves file size to DB
    process :save_file_size_in_model
    def save_file_size_in_model
      model.file_size = file.size
    end

    def extension_allowlist
      %w(jpg jpeg gif png ico svg)
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    version :thumb, unless: :is_unprocessable? do
      process :resize_to_fill => [150,100]
    end

    protected
    
    def is_unprocessable?(new_file)
      # ignore processing for gifs and svgs
      ['image/gif', 'image/svg+xml'].include? new_file.content_type
    end

  end
end
