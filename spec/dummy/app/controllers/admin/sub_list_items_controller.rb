module Admin
  class SubListItemsController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        { name: :name, type: :text, helper_text: 'The name of the sub list item.' },
        { name: :body, type: :text }
      ]
    end



  end
end