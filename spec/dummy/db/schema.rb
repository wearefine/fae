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

ActiveRecord::Schema.define(version: 20150213173312) do

  create_table "acclaims", force: true do |t|
    t.string   "score"
    t.string   "publication"
    t.text     "description"
    t.boolean  "on_stage",         default: true
    t.boolean  "on_prod",          default: false
    t.integer  "position"
    t.integer  "release_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "publication_date"
  end

  create_table "aromas", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.boolean  "live"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "release_id"
  end

  add_index "aromas", ["release_id"], name: "index_aromas_on_release_id", using: :btree

  create_table "event_releases", force: true do |t|
    t.integer  "release_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_releases", ["event_id"], name: "index_event_releases_on_event_id", using: :btree
  add_index "event_releases", ["release_id"], name: "index_event_releases_on_release_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "event_type"
    t.string   "city"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fae_files", force: true do |t|
    t.string   "name"
    t.string   "asset"
    t.integer  "fileable_id"
    t.string   "fileable_type"
    t.integer  "file_size"
    t.integer  "position",      default: 0
    t.string   "attached_as"
    t.boolean  "on_stage",      default: true
    t.boolean  "on_prod",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "required",      default: false
  end

  add_index "fae_files", ["fileable_id", "fileable_type"], name: "index_fae_files_on_fileable_id_and_fileable_type", using: :btree

  create_table "fae_images", force: true do |t|
    t.string   "name"
    t.string   "asset"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "alt"
    t.string   "caption"
    t.integer  "position",       default: 0
    t.string   "attached_as"
    t.boolean  "on_stage",       default: true
    t.boolean  "on_prod",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_size"
    t.boolean  "required",       default: false
  end

  add_index "fae_images", ["imageable_id", "imageable_type"], name: "index_fae_images_on_imageable_id_and_imageable_type", using: :btree

  create_table "fae_options", force: true do |t|
    t.string   "title"
    t.string   "time_zone"
    t.string   "colorway"
    t.string   "stage_url"
    t.string   "live_url"
    t.integer  "singleton_guard"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fae_options", ["singleton_guard"], name: "index_fae_options_on_singleton_guard", unique: true, using: :btree

  create_table "fae_roles", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fae_static_pages", force: true do |t|
    t.string   "title"
    t.integer  "position",   default: 0
    t.boolean  "on_stage",   default: true
    t.boolean  "on_prod",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "fae_static_pages", ["slug"], name: "index_fae_static_pages_on_slug", using: :btree

  create_table "fae_text_areas", force: true do |t|
    t.string   "label"
    t.text     "content"
    t.integer  "position",         default: 0
    t.boolean  "on_stage",         default: true
    t.boolean  "on_prod",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.string   "attached_as"
  end

  add_index "fae_text_areas", ["attached_as"], name: "index_fae_text_areas_on_attached_as", using: :btree
  add_index "fae_text_areas", ["contentable_id"], name: "index_fae_text_areas_on_contentable_id", using: :btree
  add_index "fae_text_areas", ["contentable_type"], name: "index_fae_text_areas_on_contentable_type", using: :btree
  add_index "fae_text_areas", ["on_prod"], name: "index_fae_text_areas_on_on_prod", using: :btree
  add_index "fae_text_areas", ["on_stage"], name: "index_fae_text_areas_on_on_stage", using: :btree
  add_index "fae_text_areas", ["position"], name: "index_fae_text_areas_on_position", using: :btree

  create_table "fae_text_fields", force: true do |t|
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.string   "attached_as"
    t.string   "label"
    t.string   "content"
    t.integer  "position",         default: 0
    t.boolean  "on_stage",         default: true
    t.boolean  "on_prod",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fae_text_fields", ["attached_as"], name: "index_fae_text_fields_on_attached_as", using: :btree
  add_index "fae_text_fields", ["contentable_id", "contentable_type"], name: "index_fae_text_fields_on_contentable_id_and_contentable_type", using: :btree
  add_index "fae_text_fields", ["on_prod"], name: "index_fae_text_fields_on_on_prod", using: :btree
  add_index "fae_text_fields", ["on_stage"], name: "index_fae_text_fields_on_on_stage", using: :btree
  add_index "fae_text_fields", ["position"], name: "index_fae_text_fields_on_position", using: :btree

  create_table "fae_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fae_users", ["confirmation_token"], name: "index_fae_users_on_confirmation_token", unique: true, using: :btree
  add_index "fae_users", ["email"], name: "index_fae_users_on_email", unique: true, using: :btree
  add_index "fae_users", ["reset_password_token"], name: "index_fae_users_on_reset_password_token", unique: true, using: :btree
  add_index "fae_users", ["role_id"], name: "index_fae_users_on_role_id", using: :btree
  add_index "fae_users", ["unlock_token"], name: "index_fae_users_on_unlock_token", unique: true, using: :btree

  create_table "locations", force: true do |t|
    t.string   "name"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["contact_id"], name: "index_locations_on_contact_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.boolean  "on_stage",   default: true
    t.boolean  "on_prod",    default: false
    t.integer  "position"
  end

  create_table "release_selling_points", force: true do |t|
    t.integer  "release_id"
    t.integer  "selling_point_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "releases", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "intro"
    t.text     "body"
    t.string   "vintage"
    t.string   "price"
    t.string   "tasting_notes_pdf"
    t.integer  "wine_id"
    t.integer  "varietal_id"
    t.boolean  "on_stage",          default: true
    t.boolean  "on_prod",           default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_url"
    t.boolean  "featured"
    t.string   "weight"
  end

  create_table "selling_points", force: true do |t|
    t.string   "name"
    t.boolean  "on_stage",   default: true
    t.boolean  "on_prod",    default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "varietals", force: true do |t|
    t.string   "name"
    t.boolean  "on_stage",   default: true
    t.boolean  "on_prod",    default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wines", force: true do |t|
    t.string   "name"
    t.boolean  "on_stage",   default: true
    t.boolean  "on_prod",    default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
