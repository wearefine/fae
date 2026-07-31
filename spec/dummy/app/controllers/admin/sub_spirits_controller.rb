module Admin
  class SubSpiritsController < Fae::NestedBaseController
    # Reached two ways: from the converted spirit form, which posts here over
    # Inertia, and from the Slim screens, which still expect the table partial
    # back. The concern only takes over the former.
    include Fae::InertiaNestedRenderable

    # Read by the parent's nested_tables option; the tout_cta on this model has
    # no converted field type yet, so the Vue form is name-only.
    def self.fae_form_fields
      [{ name: :name, type: :text, required: true }]
    end

    private

    def build_assets
      @item.build_tout_cta if @item.tout_cta.blank?
    end

  end
end