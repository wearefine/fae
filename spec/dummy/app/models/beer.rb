class Beer < ApplicationRecord
  include Fae::BaseModelConcern

  has_fae_image :image
  has_fae_seo_set :seo
  has_fae_cta :test_cta
  has_many :poly_things, as: :poly_thingable

  def fae_display_field
    name
  end

  def fae_redirect_to_form_on_create
    true
  end
end
