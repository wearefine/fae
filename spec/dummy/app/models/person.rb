class Person < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :event
end