class Location < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    name
  end

  belongs_to :contact, class_name: 'Person'
end
