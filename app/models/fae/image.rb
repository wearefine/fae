class Image < ActiveRecord::Base

  attr_accessor :redirect
  mount_uploader :asset, ImageUploader

  belongs_to :imageable, polymorphic: true, touch: true

  after_create :check_and_set_versions
  after_update :check_and_set_versions

private

  def check_and_set_versions
    unless remove_asset
      IMAGE_LOGGER.info "check_and_set_versions on Image ##{id}"
      if asset.present?
        if asset.mobile.file.present? && asset.mobile.file.exists?
          update_column(:has_mobile, true)
          IMAGE_LOGGER.info "== Image has mobile =="
        else
          update_column(:has_mobile, false)
        end

        if asset.tablet.file.present? && asset.tablet.file.exists?
          update_column(:has_tablet, true)
          IMAGE_LOGGER.info "== Image has tablet =="
        else
          update_column(:has_tablet, false)
        end
      else
        IMAGE_LOGGER.info "== Image has no asset"
      end
    end
  end

  # def crop_image
  #   asset.recreate_versions! if crop_x_changed? or crop_y_changed? or crop_x2_changed? or crop_y2_changed?
  # end

  class << self

    # all image info is set here, yes this will get big, but it's best to keep this stuff in one place!
    def sizing_info
      info = {
        hero_image: {
          min_width: 1500,
          max_width: 1500,
          min_height: 0,
          max_height: 0,
          notes: 'Any special notations go here. All image info is defined in one place: the image model'
        },
        large_ad: {
          min_width: 720,
          max_width: 720,
          min_height: 0,
          max_height: 0,
          notes: nil
        },
        small_ad: {
          min_width: 340,
          max_width: 340,
          min_height: 0,
          max_height: 0,
          notes: nil
        },
        gallery_image: {
          min_width: 1100,
          max_width: 1100,
          min_height: 0,
          max_height: 0,
          notes: nil
        }
      }
    end

  end

end