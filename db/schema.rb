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

ActiveRecord::Schema.define(version: 5) do

  create_table "bookings", force: :cascade do |t|
    t.string "name"
    t.text "notes"
    t.datetime "when"
    t.integer "duration"
    t.integer "purpose"
    t.integer "camdram_id"
    t.integer "venue_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["venue_id"], name: "index_bookings_on_venue_id"
  end

  create_table "camdram_tokens", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.boolean "expires"
    t.integer "expires_at"
    t.integer "user_id"
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

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.boolean "admin"
    t.boolean "blocked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

end
