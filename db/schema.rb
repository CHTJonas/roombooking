# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_21_181442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "attendees", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_attendees_on_email", unique: true
  end

  create_table "attendees_bookings", id: false, force: :cascade do |t|
    t.bigint "attendee_id", null: false
    t.bigint "booking_id", null: false
    t.index ["attendee_id", "booking_id"], name: "index_attendees_bookings_on_attendee_id_and_booking_id", unique: true
  end

  create_table "batch_import_results", id: false, force: :cascade do |t|
    t.string "jid", null: false
    t.datetime "queued", null: false
    t.datetime "started"
    t.datetime "completed"
    t.integer "shows_imported_successfully", array: true
    t.integer "shows_imported_unsuccessfully", array: true
    t.integer "shows_already_imported", array: true
    t.index ["jid"], name: "index_batch_import_results_on_jid", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.date "repeat_until"
    t.string "excluded_repeat_dates"
    t.integer "repeat_mode", default: 0, null: false
    t.integer "purpose", null: false
    t.bigint "room_id", null: false
    t.bigint "user_id", null: false
    t.string "camdram_model_type"
    t.bigint "camdram_model_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camdram_model_type", "camdram_model_id"], name: "index_bookings_on_camdram_model_type_and_camdram_model_id"
    t.index ["created_at"], name: "index_bookings_on_created_at", order: :desc
    t.index ["end_time"], name: "index_bookings_on_end_time"
    t.index ["repeat_mode"], name: "index_bookings_on_repeat_mode", where: "(repeat_mode <> 0)"
    t.index ["repeat_until"], name: "index_bookings_on_repeat_until"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["start_time"], name: "index_bookings_on_start_time"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "camdram_shows", force: :cascade do |t|
    t.bigint "camdram_id", null: false
    t.integer "max_rehearsals", default: 0, null: false
    t.integer "max_auditions", default: 0, null: false
    t.integer "max_meetings", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.boolean "dormant", default: false, null: false
    t.string "slack_webhook"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_camdram_shows_on_active", where: "(active = true)"
    t.index ["camdram_id"], name: "index_camdram_shows_on_camdram_id", unique: true
  end

  create_table "camdram_shows_users", id: false, force: :cascade do |t|
    t.bigint "camdram_show_id"
    t.bigint "user_id"
    t.index ["camdram_show_id"], name: "index_camdram_shows_users_on_camdram_show_id"
    t.index ["user_id"], name: "index_camdram_shows_users_on_user_id"
  end

  create_table "camdram_societies", force: :cascade do |t|
    t.bigint "camdram_id", null: false
    t.integer "max_meetings", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.string "slack_webhook"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_camdram_societies_on_active", where: "(active = true)"
    t.index ["camdram_id"], name: "index_camdram_societies_on_camdram_id", unique: true
  end

  create_table "camdram_societies_users", id: false, force: :cascade do |t|
    t.bigint "camdram_society_id"
    t.bigint "user_id"
    t.index ["camdram_society_id"], name: "index_camdram_societies_users_on_camdram_society_id"
    t.index ["user_id"], name: "index_camdram_societies_users_on_user_id"
  end

  create_table "camdram_tokens", force: :cascade do |t|
    t.binary "encrypted_access_token", null: false
    t.binary "encrypted_access_token_iv", null: false
    t.binary "encrypted_refresh_token", null: false
    t.binary "encrypted_refresh_token_iv", null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_camdram_tokens_on_created_at", order: :desc
    t.index ["encrypted_access_token_iv"], name: "index_camdram_tokens_on_encrypted_access_token_iv", unique: true
    t.index ["encrypted_refresh_token_iv"], name: "index_camdram_tokens_on_encrypted_refresh_token_iv", unique: true
    t.index ["user_id"], name: "index_camdram_tokens_on_user_id"
  end

  create_table "camdram_venues", force: :cascade do |t|
    t.bigint "camdram_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camdram_id"], name: "index_camdram_venues_on_camdram_id", unique: true
  end

  create_table "camdram_venues_rooms", id: false, force: :cascade do |t|
    t.bigint "camdram_venue_id"
    t.bigint "room_id"
    t.index ["camdram_venue_id"], name: "index_camdram_venues_rooms_on_camdram_venue_id"
    t.index ["room_id"], name: "index_camdram_venues_rooms_on_room_id"
  end

  create_table "emails", force: :cascade do |t|
    t.jsonb "message", null: false
    t.datetime "created_at"
  end

  create_table "provider_accounts", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_provider_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_provider_accounts_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_only", default: false, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "invalidated", default: false, null: false
    t.datetime "expires_at", null: false
    t.datetime "login_at", null: false
    t.inet "ip", null: false
    t.string "user_agent"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "two_factor_tokens", force: :cascade do |t|
    t.binary "encrypted_secret"
    t.binary "encrypted_secret_iv"
    t.integer "last_otp_at", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_two_factor_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "sysadmin", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "validated_at"
    t.string "validation_token"
    t.datetime "last_login"
    t.index ["admin"], name: "index_users_on_admin", where: "(admin = true)"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.datetime "created_at"
    t.string "item_subtype"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.inet "ip"
    t.string "user_agent"
    t.bigint "session"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "users"
  add_foreign_key "camdram_tokens", "users"
  add_foreign_key "provider_accounts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "two_factor_tokens", "users"
end
