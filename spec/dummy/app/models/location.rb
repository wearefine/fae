class Location < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  belongs_to :contact, class_name: 'Person'
end
