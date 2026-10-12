class EventRelease < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release, optional: true
  belongs_to :event, optional: true
end