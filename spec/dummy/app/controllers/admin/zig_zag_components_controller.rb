module Admin
  class ZigZagComponentsController < Fae::FlexComponentBaseController

    def self.fae_form_fields
      [
        { name: :name, type: :text }
      ]
    end

    def self.fae_nested_tables
      [
        {
          nested_table: :zig_zag_items,
          cols: [:heading, :on_stage, :on_prod],
          title: 'Zig Zag Items'
        }
      ]
    end


  end
end