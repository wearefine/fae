class Event < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :release
  has_many :people
end