class Beer < ApplicationRecord
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  def fae_redirect_to_form_on_create
    true
  end
end
