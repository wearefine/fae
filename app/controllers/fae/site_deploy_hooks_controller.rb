module Fae
  class SiteDeployHooksController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        { name: :environment, type: :text },
        { name: :url, type: :text, label: 'URL' }
      ]
    end


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