module Fae
  # Renders the signed-out screens -- sign in, password reset, unlock, and the
  # first-user setup form -- with Inertia + Vue instead of Slim.
  #
  # The sibling of InertiaRenderable for controllers that have no navigation,
  # no current user and no resource being edited, and whose chrome is the
  # centred login card rather than the admin shell.
  #
  # Unlike the signed-in screens these forms submit as ordinary HTML POSTs
  # rather than Inertia visits. A successful sign in lands on the dashboard,
  # which is still a Slim screen, and an Inertia visit that follows a redirect
  # into unconverted HTML pops the client's error modal. A native submit hands
  # the browser a normal document instead, and the failure paths below still
  # come back as Inertia pages because a non-Inertia request renders the full
  # layout.
  module InertiaAuthenticatable
    extend ActiveSupport::Concern
    include Fae::InertiaErrors
    include Fae::InertiaSharedProps

    included do
      inertia_config layout: 'fae/inertia'

      inertia_share do
        {
          flash: fae_inertia_flash,
          branding: fae_inertia_branding
        }
      end
    end

    private

    # Renders one auth screen. Fields are the same descriptors FaeFormField
    # reads on the signed-in forms, so both sets of screens are driven by
    # controller-side data rather than by markup.
    def render_fae_auth(page, title:, submit_path:, submit_text:, fields:,
                        intro: nil, submit_method: 'post', param_key: 'user', hidden: {})
      # Feeds the <title> through Fae::ApplicationHelper#page_title, replacing
      # the hardcoded "Login | ..." in layouts/devise.html.slim.
      @page_title_piece = title

      render inertia: page, props: {
        title: title,
        intro: intro,
        submitPath: submit_path,
        submitMethod: submit_method,
        paramKey: param_key,
        fields: fields.map { |field| fae_auth_field(field) },
        hidden: hidden,
        submitText: submit_text,
        links: fae_auth_links
      }
    end

    # Labels default off the model the way simple_form's did, so a screen only
    # names the ones it wants to change.
    def fae_auth_field(field)
      name = field[:name].to_s
      type = (field[:type] || :text).to_s

      {
        name: name,
        type: type,
        label: field[:label] || Fae::User.human_attribute_name(name),
        required: field.fetch(:required, false),
        helperText: field[:helper_text],
        # Password managers need this to offer to fill and to save; the legacy
        # forms got it from simple_form's input mappings.
        autocomplete: field[:autocomplete],
        # A checkbox has to send a real boolean: Vue writes '' straight onto
        # the DOM property, and an empty string there reads as checked.
        value: type == 'checkbox' ? !!field[:value] : field[:value].to_s
      }.compact
    end

    # Port of devise/shared/_links.slim, limited to the modules Fae::User
    # actually enables. Setup has no Devise mapping and rendered no links.
    def fae_auth_links
      return [] unless respond_to?(:devise_mapping, true) && devise_mapping.present?

      links = []

      unless controller_name == 'sessions'
        links << { text: 'Sign in', path: fae.new_user_session_path }
      end

      if devise_mapping.recoverable? && controller_name != 'passwords'
        links << { text: 'Forgot your password?', path: new_password_path(resource_name) }
      end

      if devise_mapping.lockable? &&
         resource_class.unlock_strategy_enabled?(:email) &&
         controller_name != 'unlocks'
        links << { text: "Didn't receive unlock instructions?", path: new_unlock_path(resource_name) }
      end

      links
    end

    # Devise answers through respond_with: a redirect on success, a re-render
    # of the same form on failure. Inertia has no equivalent of `render :new`,
    # so a failure redirects back with the errors stashed in the session --
    # the same shape Fae::InertiaRenderable uses. Translating here rather than
    # rewriting each action keeps Devise's own logic (flash messages,
    # sign-in-after-reset, unlocking) untouched.
    def respond_with(*args, &block)
      # Read the options without extract_options!, which would mutate `args`
      # and so strip Devise's `location:` from the bare `super` below --
      # leaving the responder to redirect to polymorphic_path(resource).
      options = args.last.is_a?(Hash) ? args.last : {}
      resource = args.first

      return super if options[:location].present?
      return super unless resource.respond_to?(:errors) && resource.errors.any?

      redirect_to fae_auth_failure_path, inertia: { errors: fae_inertia_errors(resource) }
    end

    # Where a failed submit sends the browser back to. Each controller names
    # its own, because the responder only knows it should re-render.
    def fae_auth_failure_path
      raise NotImplementedError
    end
  end
end
