module Admin
  class ArticleSubcategoriesController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        { name: :name, type: :text }
      ]
    end


  end
end