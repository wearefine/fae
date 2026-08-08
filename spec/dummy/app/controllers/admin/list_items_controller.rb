module Admin
  class ListItemsController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :name, type: :text },
              {
                name: :people,
                type: :select,
                collection: ['Alice', 'Bob', 'Charlie', 'Diana']
              },
              { name: :image, type: :image }
            ]
          }
        }
      ]
    end

    def self.fae_nested_tables
      [
        {
          nested_table: :sub_list_items,
          cols: [:name, :on_stage, :on_prod],
          title: 'Sub List Items'
        }
      ]
    end



    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end