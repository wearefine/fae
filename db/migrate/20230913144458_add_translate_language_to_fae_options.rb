class AddTranslateLanguageToFaeOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_options, :translate_language, :boolean, default: false
  end
end
