module Fae
  class GraphqlController < ApplicationController
    # If accessing from outside this domain, nullify the session
    # This allows for outside API access while preventing CSRF attacks,
    # but you'll have to authenticate your user separately
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    skip_before_action :check_disabled_environment
    skip_before_action :first_user_redirect
    skip_before_action :authenticate_user!
    skip_before_action :build_nav
    skip_before_action :set_option
    skip_before_action :detect_cancellation
    skip_before_action :set_change_user
    skip_before_action :set_locale
    skip_before_action :setup_form_manager

    http_basic_authenticate_with name: "fine", password: "fine", if: :should_set_env_flag_and_authenticate?

    def execute
      Rails.logger.info '---------------------'
      Rails.logger.info Settings.foo
      variables = prepare_variables(params[:variables])
      query = params[:query]
      operation_name = params[:operationName]
      context = {
        # Query context goes here, for example:
        # current_user: current_user,
      }
      maybe_use_gql_asset_url
      result = AppSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
      render json: result
    rescue StandardError => e
      raise e unless Rails.env.development?
      handle_error_in_development(e)
    end

    private

    def maybe_use_gql_asset_url
      ::Settings['skip_gql_asset_url'] = params['skip_gql_asset_url'] == 'true' ? true : false
    end

    def should_set_env_flag_and_authenticate?
      if Rails.env.test? || Rails.env.development? || Rails.env.remote_development?
        ::Settings['env_flag'] = 'on_stage'
        return false
      end

      # Rails.env.production:
      # Have to set it explicitly for each try because settings are cached
      if params['staging'] == 'true'
        ::Settings['env_flag'] = 'on_stage'
        return true
      end
      ::Settings['env_flag'] = 'on_prod'
      false
    end

    # Handle variables in form data, JSON body, or a blank value
    def prepare_variables(variables_param)
      case variables_param
      when String
        if variables_param.present?
          JSON.parse(variables_param) || {}
        else
          {}
        end
      when Hash
        variables_param
      when ActionController::Parameters
        variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{variables_param}"
      end
    end

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
    end
  end
end