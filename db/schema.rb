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

ActiveRecord::Schema[8.1].define(version: 2026_06_08_110533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", force: :cascade do |t|
    t.string "canvas_id"
    t.string "course_name"
    t.datetime "created_at", null: false
    t.boolean "done"
    t.datetime "due_date"
    t.boolean "due_time_confirmed", default: true, null: false
    t.integer "estimated_hours"
    t.string "source", default: "manual", null: false
    t.boolean "synced_to_calendar"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "canvas_id"], name: "index_assignments_on_user_id_and_canvas_id", unique: true, where: "(canvas_id IS NOT NULL)"
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
    t.string "banner_url"
    t.string "communication_style", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.text "description"
    t.datetime "end_time", null: false
    t.string "join_password"
    t.string "location_mode", null: false
    t.string "name", null: false
    t.datetime "start_time", null: false
    t.datetime "study_time", null: false
    t.string "tags", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_study_groups_on_creator_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "google_token"
    t.string "ical_url"
    t.string "name", null: false
    t.string "password_digest"
    t.string "provider"
    t.datetime "terms_accepted_at"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "group_memberships", "study_groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "study_group_messages", "study_groups"
  add_foreign_key "study_group_messages", "users"
  add_foreign_key "study_groups", "users", column: "creator_id"
end
