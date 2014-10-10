# encoding: utf-8
module Fae
  class ImageUploader < CarrierWave::Uploader::Base

    # Include RMagick or MiniMagick support:
    include CarrierWave::RMagick

    def extension_white_list
      %w(jpg jpeg gif png)
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    #create crop regardless, the following conditional versions rely on the cropped version.
    #yes this means the original will be duplicated but we can save space with the conditional
    #breakpoint versions below.
    # version :cropped do
    #   process :crop
    # end

    version :thumb do
      process :resize_to_fill => [150,100]
    end

    # #execute the crop!
    # def crop
    #   if model.crop_x_changed? or model.crop_y_changed? or model.crop_w_changed? or model.crop_y_changed?
    #     manipulate! do |img|
    #       x = model.crop_x.to_i
    #       y = model.crop_y.to_i
    #       w = model.crop_w.to_i
    #       h = model.crop_h.to_i
    #       img.crop!(x,y,w,h)
    #     end
    #   end
    # end

  end
end
