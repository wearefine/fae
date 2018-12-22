class AddHighlightColorToFaeOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :fae_options, :highlight_color, :string
  end
end
