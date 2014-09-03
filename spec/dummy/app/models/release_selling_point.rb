class ReleaseSellingPoint < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :release
  belongs_to :selling_point
end