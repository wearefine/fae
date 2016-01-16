class ToBeDestroyed < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

end
