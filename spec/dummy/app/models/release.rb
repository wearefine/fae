class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :wine
end
