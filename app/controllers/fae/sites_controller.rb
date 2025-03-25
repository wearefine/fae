module Fae
  class SitesController < Fae::BaseController

    private

    def set_class_variables(class_name = nil)
      klass_base = 'fae_sites'
      @klass_name = class_name || klass_base               # used in form views
      @klass = Fae::Site             # used as class reference in this controller
      @klass_singular = klass_base.singularize             # used in index views
      @klass_humanized = @klass_name.singularize.humanize  # used in index views
      @index_path = sites_path              # used in form_header partial
      @new_path = @index_path + '/new'                     # used in index_header partial
    end

    def item_params
      params.require(:site).permit!
    end

  end
end
