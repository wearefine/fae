class Wine < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_many :release
end
