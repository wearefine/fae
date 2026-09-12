module Admin
  class WinemakersController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        { name: :name, type: :text },
        { name: :winemaker_image, type: :image }
      ]
    end
  end
end
