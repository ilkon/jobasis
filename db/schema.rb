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

ActiveRecord::Schema.define(version: 2018_11_28_210533) do

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
    t.text "raw_text"
    t.bigint "employer_id"
    t.string "author"
    t.jsonb "features", default: {}, null: false
    t.datetime "last_fetched_at", null: false
    t.datetime "last_processed_at"
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
    t.datetime "last_processed_at"
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

end
