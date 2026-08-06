module Fae
  class OptionsController < ApplicationController
    include Fae::InertiaRenderable

    before_action :super_admin_only

    def edit
      @option = Option.first || Option.instance
      @option.build_logo if @option.logo.blank?
      @option.build_favicon if @option.favicon.blank?
      @deploy_hooks = DeployHook.all

      render inertia: 'Fae/Form', props: {
        title: t('fae.navbar.root_settings'),
        indexPath: fae.root_path(cancelled: true),
        submitPath: fae.option_path,
        submitMethod: 'patch',
        paramKey: 'option',
        blocks: fae_root_settings_fields.map { |field| { kind: 'field', field: field } },
        draft: false,
        deletePath: nil
      }
    end

    # PATCH/PUT /options/1
    def update
      if request.inertia?
        if @option.update(option_params)
          if @option.previous_changes.include?('site_mfa_enabled')
            Fae::User.update_mfa(option_params['site_mfa_enabled'], current_user.email)
          end
          redirect_to fae.option_path, notice: t('fae.save_notice')
        else
          redirect_to fae.option_path,
                      inertia: { errors: fae_inertia_errors(@option) },
                      flash: { alert: t('fae.save_error') }
        end
      else
        if @option.update(option_params)
          if @option.previous_changes.include?('site_mfa_enabled')
            Fae::User.update_mfa(option_params['site_mfa_enabled'], current_user.email)
          end
          flash.now[:notice] = 'Option was successfully updated.'
          redirect_to action: :edit
        else
          render :edit
        end
      end
    end

    private

      def fae_root_settings_fields
        fields = [
          { name: :title, type: :text, label: t('fae.options.project.name') },
          {
            name: :time_zone,
            type: :select,
            collection: ActiveSupport::TimeZone.all.map { |zone| [zone.to_s, zone.name] }
          },
          {
            name: :colorway,
            type: :text,
            label: t('fae.options.colorway'),
            helper_text: t('fae.options.colorway_helper')
          },
          {
            name: :live_url,
            type: :text,
            label: t('fae.options.live_url'),
            helper_text: t('fae.options.url_helper')
          },
          {
            name: :stage_url,
            type: :text,
            label: t('fae.options.stage_url'),
            helper_text: t('fae.options.url_helper')
          },
          {
            name: :logo,
            type: :image,
            helper_text: t('fae.options.logo_helper')
          },
          { name: :favicon, type: :image }
        ]

        if Fae.languages.keys.any? && ENV['TRANSLATOR_TEXT_SUBSCRIPTION_KEY'].present?
          fields << {
            name: :translate_language,
            type: :checkbox,
            label: t('fae.options.translate_language')
          }
        end

        if ENV['PRIMARY_KEY'].present? && ENV['DETERMINISTIC_KEY'].present? && ENV['KEY_DERIVATION_SALT'].present?
          fields << {
            name: :site_mfa_enabled,
            type: :checkbox,
            label: t('fae.options.mfa_enabled'),
            helper_text: 'This toggles multi-factor authentication for every admin user.'
          }
        end

        fields.map { |field| fae_inertia_form_field(@option, field) }
      end

      # Only allow a trusted parameter "white list" through.
      def option_params
        params.require(:option).permit(:title, :time_zone, :colorway, :site_mfa_enabled, :stage_url, :live_url, :translate_language, logo_attributes: [:id, :asset, :asset_cache, :attached_as, :alt, :imageable_type, :required], favicon_attributes: [:id, :asset, :asset_cache, :attached_as, :alt, :imageable_type, :required])
      end
  end
end
