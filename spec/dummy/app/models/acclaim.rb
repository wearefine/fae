class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :release
end