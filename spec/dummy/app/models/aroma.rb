class Aroma < ActiveRecord::Base
  belongs_to :release

  default_scope { order(:position) }
end
