module Fae
  class File < ActiveRecord::Base

    mount_uploader :asset, Fae::FileUploader

    belongs_to :fileable, polymorphic: true, touch: true
  end
end
