module Fae
  class SingletonPagesController < Fae::BaseController

    private

    def set_class_variables(class_name = nil)
      super
      @klass_name = @klass_name.singularize
      @klass_humanized = @klass_name.humanize
      @index_path = "/#{params[:controller].singularize}/edit"
      @submit_path = "/#{params[:controller].singularize}"
      @new_path = nil
    end

    def set_item
      @item = @klass.first || @klass.new(title: @klass.model_name.human.titleize)
    end
  end
end