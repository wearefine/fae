class EventRelease < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :release
  belongs_to :event
end