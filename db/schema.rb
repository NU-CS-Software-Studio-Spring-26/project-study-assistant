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

ActiveRecord::Schema[8.1].define(version: 2026_04_27_065000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string "canvas_id"
    t.string "course_name"
    t.datetime "created_at", null: false
    t.datetime "due_date"
    t.integer "estimated_hours"
    t.boolean "synced_to_calendar"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "study_group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["study_group_id", "user_id"], name: "index_group_memberships_on_study_group_id_and_user_id", unique: true
    t.index ["study_group_id"], name: "index_group_memberships_on_study_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "study_group_messages", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "study_group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["study_group_id", "created_at"], name: "index_study_group_messages_on_study_group_id_and_created_at"
    t.index ["study_group_id"], name: "index_study_group_messages_on_study_group_id"
    t.index ["user_id"], name: "index_study_group_messages_on_user_id"
  end

  create_table "study_groups", force: :cascade do |t|
    t.string "communication_style", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.string "location_mode", null: false
    t.string "name", null: false
    t.datetime "study_time", null: false
    t.string "tags", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_study_groups_on_creator_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "ical_url"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "group_memberships", "study_groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "study_group_messages", "study_groups"
  add_foreign_key "study_group_messages", "users"
  add_foreign_key "study_groups", "users", column: "creator_id"
end
