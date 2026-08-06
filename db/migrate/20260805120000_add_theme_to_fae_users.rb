class AddThemeToFaeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :theme, :string, null: false, default: 'light'
  end
end
