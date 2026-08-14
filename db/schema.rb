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

ActiveRecord::Schema[8.1].define(version: 2026_07_17_125123) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "abuse_report", force: :cascade do |t|
    t.text "author"
    t.text "confirmation_hash"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "issue_id", null: false
    t.text "message"
    t.datetime "resolved_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_abuse_report_on_issue_id"
  end

  create_table "active_storage_attachment", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachment_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blob", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blob_on_key", unique: true
  end

  create_table "active_storage_variant_record", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "auth_code", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "issue_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["group_id"], name: "index_auth_code_on_group_id"
    t.index ["issue_id"], name: "index_auth_code_on_issue_id"
  end

  create_table "authority", force: :cascade do |t|
    t.geometry "area", limit: {srid: 4326, type: "multi_polygon"}
    t.bigint "county_id", null: false
    t.datetime "created_at", null: false
    t.text "name"
    t.text "regional_key"
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_authority_on_area", using: :gist
    t.index ["county_id"], name: "index_authority_on_county_id"
  end

  create_table "category", force: :cascade do |t|
    t.integer "average_turnaround_time", default: 14, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "main_category_id"
    t.boolean "photo_requested", default: false, null: false
    t.bigint "sub_category_id"
    t.datetime "updated_at", null: false
    t.index ["main_category_id", "sub_category_id"], name: "index_category_on_main_category_id_and_sub_category_id", unique: true
    t.index ["main_category_id"], name: "index_category_on_main_category_id"
    t.index ["sub_category_id"], name: "index_category_on_sub_category_id"
  end

  create_table "comment", force: :cascade do |t|
    t.bigint "auth_code_id"
    t.datetime "created_at", null: false
    t.boolean "deleted", default: false, null: false
    t.bigint "issue_id", null: false
    t.text "message"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["auth_code_id"], name: "index_comment_on_auth_code_id"
    t.index ["issue_id"], name: "index_comment_on_issue_id"
    t.index ["user_id"], name: "index_comment_on_user_id"
  end

  create_table "completion", force: :cascade do |t|
    t.text "author"
    t.datetime "closed_at", precision: nil
    t.text "confirmation_hash"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "issue_id", null: false
    t.text "notice"
    t.integer "prev_issue_status"
    t.datetime "rejected_at", precision: nil
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_completion_on_issue_id"
  end

  create_table "county", force: :cascade do |t|
    t.geometry "area", limit: {srid: 4326, type: "multi_polygon"}
    t.datetime "created_at", null: false
    t.text "name"
    t.text "regional_key"
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_county_on_area", using: :gist
  end

  create_table "district", force: :cascade do |t|
    t.geometry "area", limit: {srid: 4326, type: "multi_polygon"}
    t.bigint "authority_id", default: 1, null: false
    t.datetime "created_at", null: false
    t.text "name"
    t.text "regional_key"
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_district_on_area", using: :gist
    t.index ["authority_id"], name: "index_district_on_authority_id"
  end

  create_table "district_user", id: false, force: :cascade do |t|
    t.bigint "district_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "district_id"], name: "index_district_user_on_user_id_and_district_id", unique: true
  end

  create_table "editorial_notification", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "level"
    t.datetime "notified_at", precision: nil
    t.integer "repetition"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_editorial_notification_on_user_id"
  end

  create_table "feedback", force: :cascade do |t|
    t.text "author"
    t.datetime "created_at", null: false
    t.bigint "issue_id", null: false
    t.text "message"
    t.text "recipient"
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_feedback_on_issue_id"
  end

  create_table "field_service_team_operator", id: false, force: :cascade do |t|
    t.bigint "field_service_team_id", null: false
    t.bigint "operator_id", null: false
    t.index ["field_service_team_id", "operator_id"], name: "index_field_service_team_operator_on_team_and_operator", unique: true
  end

  create_table "full_text_content", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "subject_id"
    t.text "table"
    t.datetime "updated_at", null: false
    t.index ["table", "subject_id"], name: "index_full_text_content_on_table_and_subject_id", unique: true
  end

  create_table "group", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "email"
    t.integer "kind", default: 0, null: false
    t.integer "main_user_id"
    t.text "name"
    t.boolean "reference_default", default: false, null: false
    t.integer "reference_id"
    t.text "short_name"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["reference_id"], name: "index_group_on_reference_id"
  end

  create_table "group_user", id: false, force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "group_id"], name: "index_group_user_on_user_id_and_group_id", unique: true
  end

  create_table "instance", force: :cascade do |t|
    t.geometry "area", limit: {srid: 4326, type: "multi_polygon"}
    t.datetime "created_at", null: false
    t.text "instance_url"
    t.text "name"
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_instance_on_area", using: :gist
  end

  create_table "issue", force: :cascade do |t|
    t.text "address"
    t.datetime "archived_at", precision: nil
    t.text "author"
    t.bigint "category_id", null: false
    t.text "confirmation_hash"
    t.datetime "created_at", null: false
    t.bigint "delegation_id"
    t.text "description"
    t.integer "description_status", default: 0, null: false
    t.date "expected_closure"
    t.bigint "group_id"
    t.datetime "group_responsibility_notified_at", precision: nil
    t.bigint "job_id"
    t.text "parcel"
    t.boolean "photo_requested", default: false, null: false
    t.geometry "position", limit: {srid: 4326, type: "st_point"}
    t.integer "priority", default: 1, null: false
    t.text "property_owner"
    t.boolean "responsibility_accepted", default: false, null: false
    t.datetime "reviewed_at", precision: nil
    t.integer "status"
    t.text "status_note"
    t.integer "trust_level"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_auth_code_id"
    t.bigint "updated_by_user_id"
    t.index ["archived_at"], name: "index_issue_on_archived_at"
    t.index ["category_id"], name: "index_issue_on_category_id"
    t.index ["delegation_id"], name: "index_issue_on_delegation_id"
    t.index ["group_id"], name: "index_issue_on_group_id"
    t.index ["job_id"], name: "index_issue_on_job_id"
    t.index ["position"], name: "index_issue_on_position", using: :gist
    t.index ["responsibility_accepted"], name: "index_issue_on_responsibility_accepted"
    t.index ["status"], name: "index_issue_on_status"
    t.index ["updated_by_auth_code_id"], name: "index_issue_on_updated_by_auth_code_id"
    t.index ["updated_by_user_id"], name: "index_issue_on_updated_by_user_id"
  end

  create_table "issue_delegation", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "issue_id", null: false
    t.boolean "rejected", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_issue_delegation_on_group_id"
    t.index ["issue_id"], name: "index_issue_delegation_on_issue_id"
  end

  create_table "issue_responsibility", force: :cascade do |t|
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "issue_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_issue_responsibility_on_group_id"
    t.index ["issue_id"], name: "index_issue_responsibility_on_issue_id"
  end

  create_table "job", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.bigint "group_id", null: false
    t.integer "order"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_job_on_group_id"
  end

  create_table "log_entry", force: :cascade do |t|
    t.text "action"
    t.text "attr"
    t.bigint "auth_code_id"
    t.datetime "created_at", null: false
    t.bigint "issue_id"
    t.text "new_value"
    t.bigint "new_value_id"
    t.text "old_value"
    t.bigint "old_value_id"
    t.bigint "subject_id"
    t.text "subject_name"
    t.text "table"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["attr"], name: "index_log_entry_on_attr"
    t.index ["auth_code_id"], name: "index_log_entry_on_auth_code_id"
    t.index ["issue_id"], name: "index_log_entry_on_issue_id"
    t.index ["new_value_id"], name: "index_log_entry_on_new_value_id"
    t.index ["table", "subject_id"], name: "index_log_entry_on_table_and_subject_id"
    t.index ["user_id"], name: "index_log_entry_on_user_id"
  end

  create_table "mail_blacklist", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "pattern"
    t.text "reason"
    t.text "source"
    t.datetime "updated_at", null: false
  end

  create_table "main_category", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "deleted", default: false, null: false
    t.integer "kind"
    t.text "name"
    t.datetime "updated_at", null: false
  end

  create_table "observation", force: :cascade do |t|
    t.geometry "area", limit: {srid: 4326, type: "multi_polygon"}
    t.text "category_ids"
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_observation_on_area", using: :gist
  end

  create_table "photo", force: :cascade do |t|
    t.text "author"
    t.text "confirmation_hash"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "issue_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_photo_on_issue_id"
  end

  create_table "responsibility", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_responsibility_on_category_id"
    t.index ["group_id"], name: "index_responsibility_on_group_id"
  end

  create_table "solid_queue_blocked_execution", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_execution_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_execution_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_execution_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_execution", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_execution_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_execution_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_execution", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_execution_on_job_id", unique: true
  end

  create_table "solid_queue_job", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pause", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_process", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_process_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_process_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_process_on_supervisor_id"
  end

  create_table "solid_queue_ready_execution", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_execution_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_execution", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_execution_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_execution_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_task", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_execution", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_execution_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphore", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "sub_category", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "deleted", default: false, null: false
    t.text "dms"
    t.text "name"
    t.datetime "updated_at", null: false
  end

  create_table "supporter", force: :cascade do |t|
    t.text "confirmation_hash"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "issue_id", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_supporter_on_issue_id"
  end

  create_table "user", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "email"
    t.text "first_name"
    t.boolean "group_feedback_recipient", default: false, null: false
    t.boolean "group_responsibility_recipient", default: false, null: false
    t.text "last_name"
    t.text "ldap"
    t.text "login"
    t.text "password_digest"
    t.json "password_history"
    t.datetime "password_updated_at", precision: nil
    t.integer "role", default: 2, null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
  end

  add_foreign_key "abuse_report", "issue"
  add_foreign_key "active_storage_attachment", "active_storage_blob", column: "blob_id"
  add_foreign_key "active_storage_variant_record", "active_storage_blob", column: "blob_id"
  add_foreign_key "auth_code", "group"
  add_foreign_key "auth_code", "issue"
  add_foreign_key "authority", "county"
  add_foreign_key "comment", "auth_code"
  add_foreign_key "comment", "issue"
  add_foreign_key "comment", "user"
  add_foreign_key "completion", "issue"
  add_foreign_key "district", "authority"
  add_foreign_key "editorial_notification", "user"
  add_foreign_key "feedback", "issue"
  add_foreign_key "issue", "auth_code", column: "updated_by_auth_code_id"
  add_foreign_key "issue", "category"
  add_foreign_key "issue", "group"
  add_foreign_key "issue", "group", column: "delegation_id"
  add_foreign_key "issue", "user", column: "updated_by_user_id"
  add_foreign_key "issue_delegation", "group"
  add_foreign_key "issue_delegation", "issue"
  add_foreign_key "issue_responsibility", "group"
  add_foreign_key "issue_responsibility", "issue"
  add_foreign_key "job", "group"
  add_foreign_key "log_entry", "auth_code"
  add_foreign_key "log_entry", "user"
  add_foreign_key "photo", "issue"
  add_foreign_key "responsibility", "category"
  add_foreign_key "responsibility", "group"
  add_foreign_key "solid_queue_blocked_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_execution", "solid_queue_job", column: "job_id", on_delete: :cascade
  add_foreign_key "supporter", "issue"
end
