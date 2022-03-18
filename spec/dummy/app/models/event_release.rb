class EventRelease < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release
  belongs_to :event
end