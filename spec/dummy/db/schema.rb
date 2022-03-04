# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_04_182247) do

  create_table "acclaims", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "score"
    t.string "publication"
    t.text "description"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
    t.integer "release_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "publication_date"
  end

  create_table "aromas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "position"
    t.boolean "live"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "release_id"
    t.string "slug"
    t.index ["release_id"], name: "index_aromas_on_release_id"
  end

  create_table "article_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "articles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "position"
    t.integer "article_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_category_id"], name: "index_articles_on_article_category_id"
  end

  create_table "beers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "seo_title"
    t.string "seo_description"
    t.boolean "on_stage"
    t.boolean "on_prod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "friendly"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "aroma_id"
  end

  create_table "coaches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.text "bio"
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "index_coaches_on_team_id"
  end

  create_table "event_releases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "release_id"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_event_releases_on_event_id"
    t.index ["release_id"], name: "index_event_releases_on_release_id"
  end

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.string "event_type"
    t.string "city"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
  end

  create_table "fae_changes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "changeable_id"
    t.string "changeable_type"
    t.integer "user_id"
    t.string "change_type"
    t.text "updated_attributes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changeable_id"], name: "index_fae_changes_on_changeable_id"
    t.index ["changeable_type"], name: "index_fae_changes_on_changeable_type"
    t.index ["user_id"], name: "index_fae_changes_on_user_id"
  end

  create_table "fae_deploy_hooks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "url"
    t.string "environment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["environment"], name: "index_fae_deploy_hooks_on_environment"
    t.index ["position"], name: "index_fae_deploy_hooks_on_position"
  end

  create_table "fae_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "asset"
    t.string "fileable_type"
    t.integer "fileable_id"
    t.integer "file_size"
    t.integer "position", default: 0
    t.string "attached_as"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "required", default: false
    t.index ["attached_as"], name: "index_fae_files_on_attached_as"
    t.index ["fileable_type", "fileable_id"], name: "index_fae_files_on_fileable_type_and_fileable_id"
  end

  create_table "fae_form_managers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "form_manager_model_name"
    t.integer "form_manager_model_id"
    t.text "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_manager_model_id"], name: "index_fae_form_managers_on_form_manager_model_id"
    t.index ["form_manager_model_name"], name: "index_fae_form_managers_on_form_manager_model_name"
  end

  create_table "fae_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "asset"
    t.string "imageable_type"
    t.integer "imageable_id"
    t.string "alt"
    t.string "caption"
    t.integer "position", default: 0
    t.string "attached_as"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "file_size"
    t.boolean "required", default: false
    t.index ["attached_as"], name: "index_fae_images_on_attached_as"
    t.index ["imageable_type", "imageable_id"], name: "index_fae_images_on_imageable_type_and_imageable_id"
  end

  create_table "fae_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "time_zone"
    t.string "colorway"
    t.string "stage_url"
    t.string "live_url"
    t.integer "singleton_guard"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["singleton_guard"], name: "index_fae_options_on_singleton_guard", unique: true
  end

  create_table "fae_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fae_static_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "position", default: 0
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.index ["slug"], name: "index_fae_static_pages_on_slug"
  end

  create_table "fae_text_areas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "label"
    t.text "content"
    t.integer "position", default: 0
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "contentable_id"
    t.string "contentable_type"
    t.string "attached_as"
    t.index ["attached_as"], name: "index_fae_text_areas_on_attached_as"
    t.index ["contentable_id"], name: "index_fae_text_areas_on_contentable_id"
    t.index ["contentable_type"], name: "index_fae_text_areas_on_contentable_type"
    t.index ["on_prod"], name: "index_fae_text_areas_on_on_prod"
    t.index ["on_stage"], name: "index_fae_text_areas_on_on_stage"
    t.index ["position"], name: "index_fae_text_areas_on_position"
  end

  create_table "fae_text_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "contentable_type"
    t.integer "contentable_id"
    t.string "attached_as"
    t.string "label"
    t.string "content"
    t.integer "position", default: 0
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attached_as"], name: "index_fae_text_fields_on_attached_as"
    t.index ["contentable_type", "contentable_id"], name: "index_fae_text_fields_on_contentable_type_and_contentable_id"
    t.index ["on_prod"], name: "index_fae_text_fields_on_on_prod"
    t.index ["on_stage"], name: "index_fae_text_fields_on_on_stage"
    t.index ["position"], name: "index_fae_text_fields_on_position"
  end

  create_table "fae_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name"
    t.string "last_name"
    t.integer "role_id"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "language"
    t.index ["confirmation_token"], name: "index_fae_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_fae_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_fae_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_fae_users_on_role_id"
    t.index ["unlock_token"], name: "index_fae_users_on_unlock_token", unique: true
  end

  create_table "jerseys", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contact_id"], name: "index_locations_on_contact_id"
  end

  create_table "milestones", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "year"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
  end

  create_table "players", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "number"
    t.text "bio"
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "poly_things", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "poly_thingable_type"
    t.bigint "poly_thingable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poly_thingable_type", "poly_thingable_id"], name: "index_poly_things_on_poly_thingable_type_and_poly_thingable_id"
  end

  create_table "release_notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "release_id"
    t.index ["release_id"], name: "index_release_notes_on_release_id"
  end

  create_table "release_selling_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "release_id"
    t.integer "selling_point_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "releases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "intro"
    t.text "body"
    t.string "vintage"
    t.string "price"
    t.string "tasting_notes_pdf"
    t.integer "wine_id"
    t.integer "varietal_id"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "video_url"
    t.boolean "featured"
    t.string "weight"
    t.date "release_date"
    t.date "show"
    t.date "hide"
    t.text "description"
    t.text "content"
    t.string "seo_title"
    t.string "seo_description"
    t.string "color"
    t.boolean "is_something", default: false
  end

  create_table "selling_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.text "history"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "validation_testers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "second_slug"
    t.string "email"
    t.string "url"
    t.string "phone"
    t.string "zip"
    t.string "canadian_zip"
    t.string "youtube_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "second_email"
    t.string "unique_email"
    t.string "second_url"
    t.string "second_phone"
    t.string "second_zip"
    t.string "second_youtube_url"
  end

  create_table "varietals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "winemakers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "wine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region_type"
    t.index ["wine_id"], name: "index_winemakers_on_wine_id"
  end

  create_table "wines", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name_en"
    t.boolean "on_stage", default: true
    t.boolean "on_prod", default: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_zh"
    t.string "name_ja"
    t.text "description_en"
    t.text "description_zh"
    t.text "description_ja"
    t.text "food_pairing_en"
    t.text "food_pairing_zh"
    t.text "food_pairing_ja"
  end

  add_foreign_key "articles", "article_categories"
end
