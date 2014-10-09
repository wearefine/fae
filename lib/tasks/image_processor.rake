require 'tasks/image_processor'

namespace :image_processor do

  task :check_and_set => [:environment] do |t, args|
    processor = ImageProcessor.new
    processor.check_and_set_versions
  end

end