class Location < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    name
  end

  belongs_to :contact, class_name: 'Person'

  has_fae_video :video
  has_fae_image :image
end
