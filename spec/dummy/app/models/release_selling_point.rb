class ReleaseSellingPoint < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release
  belongs_to :selling_point
end