class WineBeer < ApplicationRecord
  belongs_to :wine
  belongs_to :beer
end
