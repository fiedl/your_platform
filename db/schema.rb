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

ActiveRecord::Schema.define(:version => 20120710193308) do

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
  end

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "relationship_dag_links", :force => true do |t|
    t.integer  "ancestor_id"
    t.string   "ancestor_type"
    t.integer  "descendant_id"
    t.string   "descendant_type"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "relationships", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
  end

  create_table "workflows", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
