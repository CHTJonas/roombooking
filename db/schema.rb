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

ActiveRecord::Schema.define(version: 10) do

  create_table "bookings", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.date "repeat_until"
    t.integer "repeat_mode", default: 0, null: false
    t.integer "purpose", null: false
    t.boolean "approved", default: false, null: false
    t.integer "venue_id", null: false
    t.integer "user_id", null: false
    t.string "camdram_model_type"
    t.integer "camdram_model_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camdram_model_type", "camdram_model_id"], name: "index_bookings_on_camdram_model_type_and_camdram_model_id"
    t.index ["repeat_until"], name: "index_bookings_on_repeat_until"
    t.index ["start_time"], name: "index_bookings_on_start_time"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["venue_id"], name: "index_bookings_on_venue_id"
  end

  create_table "camdram_productions", force: :cascade do |t|
    t.integer "camdram_id", null: false
    t.integer "max_bookings", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "camdram_societies", force: :cascade do |t|
    t.integer "camdram_id", null: false
    t.integer "max_bookings", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "camdram_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "refresh_token", null: false
    t.boolean "expires", null: false
    t.integer "expires_at", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_camdram_tokens_on_user_id"
  end

  create_table "log_events", force: :cascade do |t|
    t.string "logable_type"
    t.integer "logable_id"
    t.integer "outcome"
    t.string "action"
    t.integer "interface"
    t.string "ip"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interface"], name: "index_log_events_on_interface"
    t.index ["ip"], name: "index_log_events_on_ip"
    t.index ["logable_type", "logable_id"], name: "index_log_events_on_logable_type_and_logable_id"
  end

  create_table "provider_accounts", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_provider_accounts_on_uid"
    t.index ["user_id"], name: "index_provider_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.integer "transaction_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key"
    t.index ["transaction_id"], name: "index_version_associations_on_transaction_id"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.string "ip"
    t.string "user_agent"
    t.datetime "created_at"
    t.index ["item_id"], name: "index_versions_on_item_id"
    t.index ["item_type"], name: "index_versions_on_item_type"
  end

end
