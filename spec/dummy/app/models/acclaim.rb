class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_one :pdf,
    as: :fileable,
    class_name: '::Fae::File',
    dependent: :destroy
  accepts_nested_attributes_for :pdf, allow_destroy: true

  def fae_display_field
    publication
  end

  def self.for_release_filter
    where('acclaims.score IS NOT NULL')
  end
end