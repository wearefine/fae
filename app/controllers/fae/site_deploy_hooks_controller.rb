module Fae
  class SiteDeployHooksController < Fae::NestedBaseController


    private

    def table_template_path
      "fae/site_deploy_hooks/_table"
    end

    def set_class_variables
      @klass_name = params[:controller].split('/').last
      @klass = Fae::SiteDeployHook
      @klass_singular = @klass_name.singularize
    end

  end
end