class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_fae_file :pdf

  def fae_display_field
    publication
  end

  def self.for_release_filter
    where('acclaims.score IS NOT NULL')
  end
end