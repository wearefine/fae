class ValidationTester < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    name
  end

end
