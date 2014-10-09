class ImageProcessor

  @@logger = Logger.new(Rails.root.join('log','image_processor.log'))

  def check_and_set_versions
    require 'timeout'
    @@logger.info '====================='
    @@logger.info 'Check and set image versions'
    @@logger.info '====================='
    Image.all.each do |i|
      @@logger.info "Checking Image ##{i.id}"
      if i.asset.present?
        if i.asset.mobile.file.exists?
          i.update_column(:has_mobile, true)
          @@logger.info "== Image has mobile =="
        else
          i.update_column(:has_mobile, false)
        end

        if i.asset.tablet.file.exists?
          i.update_column(:has_tablet, true)
          @@logger.info "== Image has tablet =="
        else
          i.update_column(:has_tablet, false)
        end
      else
        @@logger.info "== Image has no asset"
      end
    end
  end

end