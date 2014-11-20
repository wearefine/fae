module Fae
  class File < ActiveRecord::Base
    include Fae::AssetsValidatable

    mount_uploader :asset, Fae::FileUploader

    belongs_to :fileable, polymorphic: true, touch: true

  end
end
