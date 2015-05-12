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

ActiveRecord::Schema.define(version: 20150410010807) do

  create_table "doctors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "speciality", limit: 255
    t.text     "bio",        limit: 65535
    t.string   "image",      limit: 255
    t.integer  "site_id",    limit: 4,     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "doctors", ["site_id"], name: "fk_rails_5c443c7a0b", using: :btree

  create_table "offices", force: :cascade do |t|
    t.string   "monday",     limit: 255
    t.string   "tuesday",    limit: 255
    t.string   "wednesday",  limit: 255
    t.string   "thursday",   limit: 255
    t.string   "friday",     limit: 255
    t.string   "saturday",   limit: 255
    t.string   "sunday",     limit: 255
    t.integer  "site_id",    limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "offices", ["site_id"], name: "fk_rails_d5511b1eb5", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.string   "heading",    limit: 255
    t.text     "message",    limit: 65535
    t.integer  "site_id",    limit: 4,     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "reminders", ["site_id"], name: "fk_rails_b714b0dfce", using: :btree

  create_table "sites", force: :cascade do |t|
    t.string   "audio",      limit: 255
    t.string   "clinic_id",  limit: 255, null: false
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sites", ["clinic_id"], name: "index_sites_on_clinic_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "role",                   limit: 255
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "movie",           limit: 255
    t.integer  "recordable_id",   limit: 4
    t.string   "recordable_type", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "videos", ["recordable_type", "recordable_id"], name: "index_videos_on_recordable_type_and_recordable_id", using: :btree

  add_foreign_key "doctors", "sites"
  add_foreign_key "offices", "sites"
  add_foreign_key "reminders", "sites"
end
