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

ActiveRecord::Schema.define(version: 2019_03_29_200405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employers", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "employers_name", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "publisher_id", null: false
    t.string "publisher_key", null: false
    t.datetime "published_at"
    t.text "raw_text", null: false
    t.bigint "employer_id"
    t.string "author"
    t.integer "remoteness"
    t.integer "involvement"
    t.jsonb "skill_ids", default: [], null: false
    t.jsonb "features", default: {}, null: false
    t.datetime "last_fetched_at", null: false
    t.datetime "last_parsed_at"
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publisher_stashes", force: :cascade do |t|
    t.bigint "publisher_id", null: false
    t.string "publisher_key", null: false
    t.datetime "published_at"
    t.jsonb "content", default: {}, null: false
    t.datetime "last_fetched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id", "publisher_key"], name: "publisher_stashes_unique", unique: true
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "publishers_name", unique: true
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "synonyms", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "skills_name", unique: true
  end

  create_table "user_emails", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.string "confirm_token"
    t.datetime "confirm_sent_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirm_token"], name: "user_emails_confirm_token", unique: true
    t.index ["email"], name: "user_emails_email", unique: true
    t.index ["user_id"], name: "user_emails_user_id"
  end

  create_table "user_passwords", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "encrypted_password", null: false
    t.string "reset_token"
    t.datetime "reset_sent_at"
    t.datetime "changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_token"], name: "user_passwords_reset_token", unique: true
    t.index ["user_id"], name: "user_passwords_user_id", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "user_roles_user_id", unique: true
  end

  create_table "user_social_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "provider_id", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id", "uid"], name: "user_social_profiles_unique", unique: true
    t.index ["user_id"], name: "user_social_profiles_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "user_emails", "users", on_delete: :cascade
  add_foreign_key "user_passwords", "users", on_delete: :cascade
  add_foreign_key "user_roles", "users", on_delete: :cascade
  add_foreign_key "user_social_profiles", "users", on_delete: :cascade
end
