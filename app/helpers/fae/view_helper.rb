module Fae
  module  ViewHelper

    def fae_date_format(datetime, timezone="US/Pacific")
      datetime.in_time_zone(timezone).strftime("%b %-d, %Y%l:%M%P %Z")
    end
  end
end