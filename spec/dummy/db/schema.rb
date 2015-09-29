# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150929195433) do

  create_table "acclaims", force: :cascade do |t|
    t.string   "score",            limit: 255
    t.string   "publication",      limit: 255
    t.text     "description",      limit: 65535
    t.boolean  "on_stage",                       default: true
    t.boolean  "on_prod",                        default: false
    t.integer  "position",         limit: 4
    t.integer  "release_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "publication_date"
  end

  create_table "aromas", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "position",    limit: 4
    t.boolean  "live"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "release_id",  limit: 4
    t.string   "slug",        limit: 255
  end

  add_index "aromas", ["release_id"], name: "index_aromas_on_release_id", using: :btree

  create_table "cats", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.boolean  "friendly"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "coaches", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "role",       limit: 255
    t.text     "bio",        limit: 65535
    t.integer  "team_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coaches", ["team_id"], name: "index_coaches_on_team_id", using: :btree

  create_table "event_releases", force: :cascade do |t|
    t.integer  "release_id", limit: 4
    t.integer  "event_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_releases", ["event_id"], name: "index_event_releases_on_event_id", using: :btree
  add_index "event_releases", ["release_id"], name: "index_event_releases_on_release_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "event_type", limit: 255
    t.string   "city",       limit: 255
    t.integer  "person_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fae_files", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "asset",         limit: 255
    t.integer  "fileable_id",   limit: 4
    t.string   "fileable_type", limit: 255
    t.integer  "file_size",     limit: 4
    t.integer  "position",      limit: 4,   default: 0
    t.string   "attached_as",   limit: 255
    t.boolean  "on_stage",                  default: true
    t.boolean  "on_prod",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "required",                  default: false
  end

  add_index "fae_files", ["fileable_id", "fileable_type"], name: "index_fae_files_on_fileable_id_and_fileable_type", using: :btree

  create_table "fae_images", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "asset",          limit: 255
    t.integer  "imageable_id",   limit: 4
    t.string   "imageable_type", limit: 255
    t.string   "alt",            limit: 255
    t.string   "caption",        limit: 255
    t.integer  "position",       limit: 4,   default: 0
    t.string   "attached_as",    limit: 255
    t.boolean  "on_stage",                   default: true
    t.boolean  "on_prod",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_size",      limit: 4
    t.boolean  "required",                   default: false
  end

  add_index "fae_images", ["imageable_id", "imageable_type"], name: "index_fae_images_on_imageable_id_and_imageable_type", using: :btree

  create_table "fae_options", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "time_zone",       limit: 255
    t.string   "colorway",        limit: 255
    t.string   "stage_url",       limit: 255
    t.string   "live_url",        limit: 255
    t.integer  "singleton_guard", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fae_options", ["singleton_guard"], name: "index_fae_options_on_singleton_guard", unique: true, using: :btree

  create_table "fae_roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fae_static_pages", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "position",   limit: 4,   default: 0
    t.boolean  "on_stage",               default: true
    t.boolean  "on_prod",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  add_index "fae_static_pages", ["slug"], name: "index_fae_static_pages_on_slug", using: :btree

  create_table "fae_text_areas", force: :cascade do |t|
    t.string   "label",            limit: 255
    t.text     "content",          limit: 65535
    t.integer  "position",         limit: 4,     default: 0
    t.boolean  "on_stage",                       default: true
    t.boolean  "on_prod",                        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contentable_id",   limit: 4
    t.string   "contentable_type", limit: 255
    t.string   "attached_as",      limit: 255
  end

  add_index "fae_text_areas", ["attached_as"], name: "index_fae_text_areas_on_attached_as", using: :btree
  add_index "fae_text_areas", ["contentable_id"], name: "index_fae_text_areas_on_contentable_id", using: :btree
  add_index "fae_text_areas", ["contentable_type"], name: "index_fae_text_areas_on_contentable_type", using: :btree
  add_index "fae_text_areas", ["on_prod"], name: "index_fae_text_areas_on_on_prod", using: :btree
  add_index "fae_text_areas", ["on_stage"], name: "index_fae_text_areas_on_on_stage", using: :btree
  add_index "fae_text_areas", ["position"], name: "index_fae_text_areas_on_position", using: :btree

  create_table "fae_text_fields", force: :cascade do |t|
    t.integer  "contentable_id",   limit: 4
    t.string   "contentable_type", limit: 255
    t.string   "attached_as",      limit: 255
    t.string   "label",            limit: 255
    t.string   "content",          limit: 255
    t.integer  "position",         limit: 4,   default: 0
    t.boolean  "on_stage",                     default: true
    t.boolean  "on_prod",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fae_text_fields", ["attached_as"], name: "index_fae_text_fields_on_attached_as", using: :btree
  add_index "fae_text_fields", ["contentable_id", "contentable_type"], name: "index_fae_text_fields_on_contentable_id_and_contentable_type", using: :btree
  add_index "fae_text_fields", ["on_prod"], name: "index_fae_text_fields_on_on_prod", using: :btree
  add_index "fae_text_fields", ["on_stage"], name: "index_fae_text_fields_on_on_stage", using: :btree
  add_index "fae_text_fields", ["position"], name: "index_fae_text_fields_on_position", using: :btree

  create_table "fae_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.integer  "role_id",                limit: 4
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",               limit: 255
  end

  add_index "fae_users", ["confirmation_token"], name: "index_fae_users_on_confirmation_token", unique: true, using: :btree
  add_index "fae_users", ["email"], name: "index_fae_users_on_email", unique: true, using: :btree
  add_index "fae_users", ["reset_password_token"], name: "index_fae_users_on_reset_password_token", unique: true, using: :btree
  add_index "fae_users", ["role_id"], name: "index_fae_users_on_role_id", using: :btree
  add_index "fae_users", ["unlock_token"], name: "index_fae_users_on_unlock_token", unique: true, using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "contact_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["contact_id"], name: "index_locations_on_contact_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",   limit: 4
    t.boolean  "on_stage",               default: true
    t.boolean  "on_prod",                default: false
    t.integer  "position",   limit: 4
  end

  create_table "players", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "number",     limit: 255
    t.text     "bio",        limit: 65535
    t.integer  "team_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["team_id"], name: "index_players_on_team_id", using: :btree

  create_table "release_selling_points", force: :cascade do |t|
    t.integer  "release_id",       limit: 4
    t.integer  "selling_point_id", limit: 4
    t.integer  "position",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "releases", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.text     "intro",             limit: 65535
    t.text     "body",              limit: 65535
    t.string   "vintage",           limit: 255
    t.string   "price",             limit: 255
    t.string   "tasting_notes_pdf", limit: 255
    t.integer  "wine_id",           limit: 4
    t.integer  "varietal_id",       limit: 4
    t.boolean  "on_stage",                        default: true
    t.boolean  "on_prod",                         default: false
    t.integer  "position",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_url",         limit: 255
    t.boolean  "featured"
    t.string   "weight",            limit: 255
    t.date     "release_date"
    t.date     "show"
    t.date     "hide"
  end

  create_table "selling_points", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "on_stage",               default: true
    t.boolean  "on_prod",                default: false
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasting_notes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "active"
    t.integer  "position",   limit: 4
    t.integer  "release_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasting_notes", ["release_id"], name: "index_tasting_notes_on_release_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "city",       limit: 255
    t.text     "history",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "validation_testers", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "slug",               limit: 255
    t.string   "second_slug",        limit: 255
    t.string   "email",              limit: 255
    t.string   "url",                limit: 255
    t.string   "phone",              limit: 255
    t.string   "zip",                limit: 255
    t.string   "canadian_zip",       limit: 255
    t.string   "youtube_url",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "second_email",       limit: 255
    t.string   "unique_email",       limit: 255
    t.string   "second_url",         limit: 255
    t.string   "second_phone",       limit: 255
    t.string   "second_zip",         limit: 255
    t.string   "second_youtube_url", limit: 255
  end

  create_table "varietals", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "on_stage",               default: true
    t.boolean  "on_prod",                default: false
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wines", force: :cascade do |t|
    t.string   "name_en",         limit: 255
    t.boolean  "on_stage",                      default: true
    t.boolean  "on_prod",                       default: false
    t.integer  "position",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_zh",         limit: 255
    t.string   "name_ja",         limit: 255
    t.text     "description_en",  limit: 65535
    t.text     "description_zh",  limit: 65535
    t.text     "description_ja",  limit: 65535
    t.text     "food_pairing_en", limit: 65535
    t.text     "food_pairing_zh", limit: 65535
    t.text     "food_pairing_ja", limit: 65535
  end

end
