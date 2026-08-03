module Fae
  # Props every Fae Inertia screen carries, signed in or not.
  #
  # Kept apart from InertiaRenderable so the signed-out screens can share them
  # without dragging in navigation, the current user, or the @klass/@item pair
  # that Fae::BaseController sets up.
  module InertiaSharedProps
    extend ActiveSupport::Concern

    private

    # Every flash key, not a hardcoded notice/alert pair: Fae also sets
    # flash[:error] (a failed destroy, an unauthorized redirect), and the Slim
    # partial this replaces iterated the whole hash too. Keys stay strings so
    # they map straight onto the alert's modifier class.
    def fae_inertia_flash
      flash.to_hash.reject { |_type, message| message.blank? }
    end

    # The admin's identity, as configured under /admin/root. Every signed-in
    # screen has the header to carry it; the login screen does not, which is
    # why it travels as a prop rather than being baked into the layout.
    def fae_inertia_branding
      option = @option || Fae::Option.instance
      logo = option.logo

      {
        title: option.title,
        version: Fae::VERSION,
        # Nil when no logo has been uploaded -- the auth layout falls back to
        # the title, exactly as layouts/devise.html.slim did.
        logoUrl: (logo.asset_url if logo.present? && logo.asset.present?)
      }
    end
  end
end
