class WineBeer < ApplicationRecord
  belongs_to :wine, optional: true
  belongs_to :beer, optional: true
end
