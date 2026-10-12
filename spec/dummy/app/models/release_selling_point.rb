class ReleaseSellingPoint < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release, optional: true
  belongs_to :selling_point, optional: true
end