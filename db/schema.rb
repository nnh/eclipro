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

ActiveRecord::Schema.define(version: 20170808060701) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "author_users", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_author_users_on_protocol_id"
    t.index ["user_id"], name: "index_author_users_on_user_id"
  end

  create_table "co_author_users", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_co_author_users_on_protocol_id"
    t.index ["user_id"], name: "index_co_author_users_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.integer "parent_id"
    t.boolean "resolve"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "content_id"
    t.index ["content_id"], name: "index_comments_on_content_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contents", force: :cascade do |t|
    t.bigint "protocol_id"
    t.text "body"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "no"
    t.string "title"
    t.boolean "editable"
    t.index ["protocol_id"], name: "index_contents_on_protocol_id"
  end

  create_table "principal_investigator_users", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_principal_investigator_users_on_protocol_id"
    t.index ["user_id"], name: "index_principal_investigator_users_on_user_id"
  end

  create_table "protocols", force: :cascade do |t|
    t.string "title", null: false
    t.integer "status", default: 0, null: false
    t.float "version", default: 0.001, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "short_title"
    t.string "protocol_number"
    t.string "nct_number"
    t.text "sponsors"
    t.string "sponsor_other"
    t.string "entity_funding_name"
    t.text "study_agent"
    t.integer "has_ide"
    t.integer "has_ind"
    t.integer "compliance", default: 0
  end

  create_table "reviewer_users", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_reviewer_users_on_protocol_id"
    t.index ["user_id"], name: "index_reviewer_users_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "no"
    t.string "title"
    t.text "template"
    t.text "instructions"
    t.text "example"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "token"
    t.string "locale"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "author_users", "protocols"
  add_foreign_key "author_users", "users"
  add_foreign_key "co_author_users", "protocols"
  add_foreign_key "co_author_users", "users"
  add_foreign_key "comments", "contents"
  add_foreign_key "comments", "users"
  add_foreign_key "contents", "protocols"
  add_foreign_key "principal_investigator_users", "protocols"
  add_foreign_key "principal_investigator_users", "users"
  add_foreign_key "reviewer_users", "protocols"
  add_foreign_key "reviewer_users", "users"
end
