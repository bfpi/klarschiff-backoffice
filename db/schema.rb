# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_16_114001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "abuse_report", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "message"
    t.text "author"
    t.text "confirmation_hash"
    t.datetime "confirmed_at"
    t.datetime "resolved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_abuse_report_on_issue_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "auth_code", force: :cascade do |t|
    t.uuid "uuid"
    t.bigint "issue_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_auth_code_on_group_id"
    t.index ["issue_id"], name: "index_auth_code_on_issue_id"
  end

  create_table "authority", force: :cascade do |t|
    t.text "regional_key"
    t.text "name"
    t.geometry "area", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.bigint "county_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["county_id"], name: "index_authority_on_county_id"
  end

  create_table "category", force: :cascade do |t|
    t.integer "average_turnaround_time", default: 14, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "main_category_id"
    t.bigint "sub_category_id"
    t.index ["main_category_id", "sub_category_id"], name: "index_category_on_main_category_id_and_sub_category_id", unique: true
    t.index ["main_category_id"], name: "index_category_on_main_category_id"
    t.index ["sub_category_id"], name: "index_category_on_sub_category_id"
  end

  create_table "comment", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "message"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "auth_code_id"
    t.index ["auth_code_id"], name: "index_comment_on_auth_code_id"
    t.index ["issue_id"], name: "index_comment_on_issue_id"
    t.index ["user_id"], name: "index_comment_on_user_id"
  end

  create_table "county", force: :cascade do |t|
    t.text "regional_key"
    t.text "name"
    t.geometry "area", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "district", force: :cascade do |t|
    t.text "name"
    t.geometry "area", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "regional_key"
    t.bigint "authority_id", default: 1, null: false
    t.index ["authority_id"], name: "index_district_on_authority_id"
  end

  create_table "district_user", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "district_id", null: false
    t.index ["user_id", "district_id"], name: "index_district_user_on_user_id_and_district_id", unique: true
  end

  create_table "editorial_notification", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "level"
    t.integer "repetition"
    t.datetime "notified_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_editorial_notification_on_user_id"
  end

  create_table "feedback", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "message"
    t.text "author"
    t.text "recipient"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_feedback_on_issue_id"
  end

  create_table "field_service_team_operator", id: false, force: :cascade do |t|
    t.bigint "field_service_team_id", null: false
    t.bigint "operator_id", null: false
    t.index ["field_service_team_id", "operator_id"], name: "index_field_service_team_operator_on_team_and_operator", unique: true
  end

  create_table "group", force: :cascade do |t|
    t.text "name"
    t.text "short_name"
    t.integer "kind", default: 0, null: false
    t.text "email"
    t.integer "main_user_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.integer "reference_id"
    t.boolean "reference_default", default: false, null: false
  end

  create_table "group_user", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.index ["user_id", "group_id"], name: "index_group_user_on_user_id_and_group_id", unique: true
  end

  create_table "instance", force: :cascade do |t|
    t.text "name"
    t.text "instance_url"
    t.geometry "area", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue", force: :cascade do |t|
    t.geometry "position", limit: {:srid=>4326, :type=>"st_point"}
    t.text "address"
    t.datetime "archived_at"
    t.text "author"
    t.text "description"
    t.integer "description_status", default: 0, null: false
    t.datetime "reviewed_at"
    t.text "confirmation_hash"
    t.integer "priority", default: 1, null: false
    t.integer "status"
    t.text "status_note"
    t.bigint "category_id", null: false
    t.text "parcel"
    t.text "property_owner"
    t.boolean "photo_requested", default: false, null: false
    t.integer "trust_level"
    t.date "expected_closure"
    t.boolean "responsibility_accepted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "delegation_id"
    t.bigint "group_id"
    t.bigint "job_id"
    t.index ["category_id"], name: "index_issue_on_category_id"
    t.index ["delegation_id"], name: "index_issue_on_delegation_id"
    t.index ["group_id"], name: "index_issue_on_group_id"
    t.index ["job_id"], name: "index_issue_on_job_id"
    t.index ["position"], name: "index_issue_on_position", using: :gist
  end

  create_table "job", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.integer "status"
    t.integer "order"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_job_on_group_id"
  end

  create_table "log_entry", force: :cascade do |t|
    t.text "table"
    t.text "attr"
    t.bigint "issue_id"
    t.bigint "subject_id"
    t.text "subject_name"
    t.text "action"
    t.text "old_value"
    t.text "new_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "auth_code_id"
    t.index ["attr"], name: "index_log_entry_on_attr"
    t.index ["auth_code_id"], name: "index_log_entry_on_auth_code_id"
    t.index ["issue_id"], name: "index_log_entry_on_issue_id"
    t.index ["table", "subject_id"], name: "index_log_entry_on_table_and_subject_id"
    t.index ["user_id"], name: "index_log_entry_on_user_id"
  end

  create_table "mail_blacklist", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "pattern"
    t.text "source"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "main_category", force: :cascade do |t|
    t.integer "kind"
    t.text "name"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "observation", force: :cascade do |t|
    t.text "key"
    t.text "category_ids"
    t.geometry "area", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "photo", force: :cascade do |t|
    t.text "author"
    t.bigint "issue_id", null: false
    t.integer "status"
    t.text "confirmation_hash"
    t.datetime "confirmed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_photo_on_issue_id"
  end

  create_table "responsibility", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["category_id"], name: "index_responsibility_on_category_id"
    t.index ["group_id"], name: "index_responsibility_on_group_id"
  end

  create_table "sub_category", force: :cascade do |t|
    t.text "name"
    t.text "dms"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "supporter", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "confirmation_hash"
    t.datetime "confirmed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_supporter_on_issue_id"
  end

  create_table "user", force: :cascade do |t|
    t.text "first_name"
    t.text "last_name"
    t.text "email"
    t.text "login"
    t.text "password_digest"
    t.text "ldap"
    t.boolean "group_feedback_recipient", default: false, null: false
    t.integer "role", default: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "abuse_report", "issue"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auth_code", "\"group\"", column: "group_id"
  add_foreign_key "auth_code", "issue"
  add_foreign_key "authority", "county"
  add_foreign_key "comment", "\"user\"", column: "user_id"
  add_foreign_key "comment", "auth_code"
  add_foreign_key "comment", "issue"
  add_foreign_key "district", "authority"
  add_foreign_key "editorial_notification", "\"user\"", column: "user_id"
  add_foreign_key "feedback", "issue"
  add_foreign_key "issue", "\"group\"", column: "delegation_id"
  add_foreign_key "issue", "\"group\"", column: "group_id"
  add_foreign_key "issue", "category"
  add_foreign_key "job", "\"group\"", column: "group_id"
  add_foreign_key "log_entry", "\"user\"", column: "user_id"
  add_foreign_key "log_entry", "auth_code"
  add_foreign_key "photo", "issue"
  add_foreign_key "responsibility", "\"group\"", column: "group_id"
  add_foreign_key "responsibility", "category"
  add_foreign_key "supporter", "issue"
end
