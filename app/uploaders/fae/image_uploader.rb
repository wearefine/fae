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

    # #create tablet version only if cropping is wider than 1024
    version :tablet, :if => :is_over_tablet_size? do
      process :resize_to_limit => [1024,0]
    end

    # #create mobile version only if cropping is wider than 480
    version :mobile, :if => :is_over_mobile_size? do
      process :resize_to_limit => [480,0]
    end

    #detect if crop is over tablet size
    def is_over_tablet_size?(image)
      IMAGE_LOGGER.info "=== tablet check for image (image_uploader)"
      manipulate! do |image|
        return image.columns.to_i > 1024
      end
    end

    # def resize_to_fill_for_tablet(image)
    #  manipulate! do |img|
    #    if img.columns.to_i > 1024
    #      width_percentage = 1024.0/img.columns.to_f
    #      new_height = width_percentage*img.rows.to_f
    #      img.resize_to_fill!(1024,new_height.to_i)
    #    end
    #  end
    # end

    # #detect if crop is over mobile size
    def is_over_mobile_size?(image)
      IMAGE_LOGGER.info "=== mobile check for image (image_uploader)"
      manipulate! do |image|
        return image.columns.to_i > 480
      end
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
