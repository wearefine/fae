class Location < ActiveRecord::Base
  include Fae::BaseModelConcern

  has_fae_video :video
  has_fae_image :image

  def fae_display_field
    name
  end

  belongs_to :contact, class_name: 'Person'
end
