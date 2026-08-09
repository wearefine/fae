module Fae
  class DeployController < ApplicationController
    before_action :admin_only

    include Fae::InertiaRenderable
    include Fae::ApplicationHelper

    def index
      if params[:site_id].present?
        @site = Site.find_by_id(params[:site_id])
        @deploy_hooks = @site&.site_deploy_hooks || []
      else
        @deploy_hooks = DeployHook.all
      end

      enabled = deploy_available_for?(@site)

      heading = t('fae.deploy.page.heading')
      heading = "#{heading} - #{@site.name}" if @site.present?

      render inertia: 'Fae/Deploy', props: {
        title: heading,
        intro: t('fae.deploy.page.intro'),
        enabled: enabled,
        siteId: @site&.id,
        deployHooks: Array(@deploy_hooks).map do |hook|
          {
            environment: hook.environment.to_s,
            label: "#{t('fae.deploy.ctas.deploy')} #{hook.environment.to_s.titleize}"
          }
        end,
        deployListPath: fae.deploy_deploys_list_path,
        deployPath: fae.deploy_deploy_site_path,
        helpPath: fae.help_path,
        labels: {
          runningHeading: t('fae.deploy.table.deploying_heading'),
          pastHeading: t('fae.deploy.table.past_heading'),
          deployingHelper: t('fae.deploy.table.deploying_helper'),
          activity: t('fae.deploy.table.title'),
          deployed: t('fae.deploy.table.deployed'),
          duration: t('fae.deploy.table.duration'),
          context: t('fae.deploy.table.context'),
          error: t('fae.deploy.table.error_msg'),
          noDeploys: t('fae.deploy.table.no_deploys')
        }
      }
    end

    def deploys_list
      site = Site.find_by_id(params[:fae_site_id]) if params[:fae_site_id].present?

      unless deploy_available_for?(site)
        render json: { success: false, error: 'Netlify configuration is missing.' }, status: :service_unavailable
        return
      end

      deploys = Fae::NetlifyApi.new(params[:fae_site_id]).get_deploys
      render json: deploys || []
    end

    def deploy_site
      site = Site.find_by_id(params[:fae_site_id]) if params[:fae_site_id].present?

      unless deploy_available_for?(site)
        render json: { success: false, error: 'Netlify configuration is missing.' }, status: :service_unavailable
        return
      end

      if Fae::NetlifyApi.new(params['fae_site_id']).run_deploy(params['deploy_hook_type'], current_user)
        return render json: { success: true }
      end
      render json: { success: false }, status: :unprocessable_entity
    end

    private

    def netlify_credentials_enabled?
      Fae.netlify.present? &&
        Fae.netlify[:api_user].present? &&
        Fae.netlify[:api_token].present? &&
        Fae.netlify[:api_base].present?
    end

    def deploy_available_for?(site)
      return false unless netlify_credentials_enabled?

      if site.present?
        site.netlify_site.present? && site.netlify_site_id.present?
      else
        Fae.netlify[:site].present? && Fae.netlify[:site_id].present?
      end
    end

  end
end
