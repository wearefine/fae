module Fae
  class BaseSingletonController < Fae::BaseController

  private

    def set_class_variables(class_name = nil)
      super
      @index_path = url_for(action: :edit, only_path: true)
      @new_path = nil
    end

    def set_item
      @item = @klass.instance
    end

  end
end
