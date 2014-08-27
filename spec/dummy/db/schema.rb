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

ActiveRecord::Schema.define(version: 20140827225157) do

  create_table "fae_roles", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

end
