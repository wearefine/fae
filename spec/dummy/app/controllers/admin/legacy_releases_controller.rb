## Deprecate in Fae 2.0 ##
# The Legacy Releases section is a duplicate
# of Releases with the views in the old (yet
# still supported) class and markup structure.
# This section is soley for backwards compatible
# QA and will be deprecated in Fae 2.0

module Admin
  class LegacyReleasesController < Fae::BaseController

    private

    def build_assets
      @item.build_bottle_shot if @item.bottle_shot.blank?
      @item.build_hero_image if @item.hero_image.blank?
      @item.build_label_pdf if @item.label_pdf.blank?
    end

    def attributes_for_cloning
      [:name, :slug, :intro, :body, :wine_id, :release_date]
    end

    def associations_for_cloning
      [:aromas, :events]
    end

    def set_class_variables(class_name = nil)
      klass_base = 'releases'
      @klass_name = class_name || klass_base               # used in form views
      @klass = klass_base.classify.constantize             # used as class reference in this controller
      @klass_singular = klass_base.singularize             # used in index views
      @klass_humanized = @klass_name.singularize.humanize  # used in index views
      @index_path = '/' + params[:controller]              # used in form_header and form_buttons partials
      @new_path = @index_path + '/new'                     # used in index_header partial
    end

    def use_pagination
      true
    end

  end
end
