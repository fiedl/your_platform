# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130329231902) do

  create_table "attachments", :force => true do |t|
    t.string   "file"
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "content_type"
    t.integer  "file_size"
  end

  create_table "bookmarks", :force => true do |t|
    t.integer  "bookmarkable_id"
    t.string   "bookmarkable_type"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "bv_mappings", :force => true do |t|
    t.string   "bv_name"
    t.string   "plz"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dag_links", :force => true do |t|
    t.integer  "ancestor_id"
    t.string   "ancestor_type"
    t.integer  "descendant_id"
    t.string   "descendant_type"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "deleted_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "flags", :force => true do |t|
    t.string   "key"
    t.integer  "flagable_id"
    t.string   "flagable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "geo_locations", :force => true do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country"
    t.string   "country_code"
    t.string   "city"
    t.string   "postal_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "queried_at"
  end

  add_index "geo_locations", ["address"], :name => "index_geo_locations_on_address"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "token"
    t.string   "extensive_name"
    t.string   "internal_token"
  end

  create_table "nav_nodes", :force => true do |t|
    t.string   "url_component"
    t.string   "breadcrumb_item"
    t.string   "menu_item"
    t.boolean  "slim_breadcrumb"
    t.boolean  "slim_url"
    t.boolean  "slim_menu"
    t.boolean  "hidden_menu"
    t.integer  "navable_id"
    t.string   "navable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "redirect_to"
  end

  create_table "posts", :force => true do |t|
    t.string   "subject"
    t.text     "text"
    t.integer  "group_id"
    t.integer  "author_user_id"
    t.string   "external_author"
    t.datetime "sent_at"
    t.boolean  "sticky"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "profile_fields", :force => true do |t|
    t.integer  "profileable_id"
    t.string   "label"
    t.string   "type"
    t.text     "value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "profileable_type"
    t.integer  "parent_id"
  end

  create_table "relationships", :force => true do |t|
    t.string   "name"
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "status_group_membership_infos", :force => true do |t|
    t.integer  "membership_id"
    t.integer  "promoted_by_workflow_id"
    t.integer  "promoted_on_event_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "user_accounts", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "user_id"
    t.string   "password_digest"
  end

  create_table "users", :force => true do |t|
    t.string   "alias"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "female"
  end

  create_table "workflow_kit_parameters", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "parameterable_id"
    t.string   "parameterable_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "workflow_kit_steps", :force => true do |t|
    t.integer  "sequence_index"
    t.integer  "workflow_id"
    t.string   "brick_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "workflow_kit_workflows", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "workflows", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
