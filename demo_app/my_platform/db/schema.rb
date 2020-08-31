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

ActiveRecord::Schema.define(version: 20200812200056) do

  create_table "activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "trackable_type"
    t.integer  "trackable_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "key"
    t.text     "parameters",     limit: 65535
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "file"
    t.string   "title"
    t.text     "description",    limit: 65535
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "author_user_id"
    t.integer  "width"
    t.integer  "height"
    t.string   "type"
    t.index ["author_user_id"], name: "attachments_author_user_id_fk", using: :btree
  end

  create_table "auth_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "token"
    t.integer  "user_id"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.integer  "post_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["token"], name: "index_auth_tokens_on_token", unique: true, using: :btree
  end

  create_table "badges_sashes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", default: false
    t.datetime "created_at"
    t.index ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id", using: :btree
    t.index ["badge_id"], name: "index_badges_sashes_on_badge_id", using: :btree
    t.index ["sash_id"], name: "index_badges_sashes_on_sash_id", using: :btree
  end

  create_table "beta_invitations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "beta_id"
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "betas", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.integer  "max_invitations_per_inviter"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "description",                 limit: 65535
    t.string   "key"
  end

  create_table "bookmarks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "bookmarkable_id"
    t.string   "bookmarkable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "bookmarks_user_id_fk", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text     "text",             limit: 65535
    t.integer  "author_user_id"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "dag_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "ancestor_id"
    t.string   "ancestor_type"
    t.integer  "descendant_id"
    t.string   "descendant_type"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_to",        precision: 6
    t.datetime "valid_from",      precision: 6
    t.string   "type"
    t.index ["ancestor_id", "ancestor_type", "direct"], name: "dag_ancestor", using: :btree
    t.index ["descendant_id", "descendant_type"], name: "dag_descendant", using: :btree
  end

  create_table "decision_making_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.text     "description", limit: 65535
    t.integer  "process_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "decision_making_processes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.string   "type"
    t.text     "wording",              limit: 65535
    t.text     "rationale",            limit: 65535
    t.integer  "proposer_group_id"
    t.integer  "scope_group_id"
    t.integer  "creator_user_id"
    t.string   "required_majority"
    t.datetime "proposed_at"
    t.datetime "opened_for_voting_at"
    t.datetime "deadline"
    t.datetime "decided_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "decision_making_signatures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "signable_type"
    t.string   "signable_id"
    t.string   "verified_by"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "decision_making_votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "process_id"
    t.integer  "option_id"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.text     "description",               limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.boolean  "publish_on_global_website"
    t.boolean  "publish_on_local_website"
    t.integer  "group_id"
  end

  create_table "flags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "key"
    t.integer  "flagable_id"
    t.string   "flagable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["flagable_id", "flagable_type", "key"], name: "flagable_key", using: :btree
    t.index ["flagable_id", "flagable_type"], name: "flagable", using: :btree
    t.index ["key"], name: "key", using: :btree
  end

  create_table "geo_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "address"
    t.float    "latitude",     limit: 24
    t.float    "longitude",    limit: 24
    t.string   "country"
    t.string   "country_code"
    t.string   "city"
    t.string   "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "queried_at"
    t.string   "street"
    t.string   "state"
    t.index ["address"], name: "index_geo_locations_on_address", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "extensive_name"
    t.string   "internal_token"
    t.text     "body",                       limit: 65535
    t.string   "type"
    t.string   "mailing_list_sender_filter"
    t.string   "subdomain"
  end

  create_table "impressions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message",             limit: 65535
    t.text     "referrer",            limit: 65535
    t.text     "params",              limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { params: 255 }, using: :btree
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { message: 255 }, using: :btree
    t.index ["user_id"], name: "index_impressions_on_user_id", using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.text     "description",          limit: 65535
    t.integer  "reference_id"
    t.string   "reference_type"
    t.datetime "resolved_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "responsible_admin_id"
    t.integer  "author_id"
  end

  create_table "last_seen_activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "description"
    t.integer  "link_to_object_id"
    t.string   "link_to_object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "last_seen_activities_user_id_fk", using: :btree
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.float    "longitude",   limit: 24
    t.float    "latitude",    limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "mentions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "who_user_id"
    t.integer  "whom_user_id"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["whom_user_id"], name: "index_mentions_on_whom_user_id", using: :btree
  end

  create_table "merit_actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",                  default: false
    t.string   "target_model"
    t.integer  "target_id"
    t.text     "target_data",   limit: 65535
    t.boolean  "processed",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merit_activity_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "score_id"
    t.integer  "num_points", default: 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "sash_id"
    t.string  "category", default: "default"
  end

  create_table "nav_nodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "url_component"
    t.string   "breadcrumb_item"
    t.string   "menu_item"
    t.boolean  "slim_breadcrumb"
    t.boolean  "slim_url"
    t.boolean  "slim_menu"
    t.boolean  "hidden_menu"
    t.string   "navable_type"
    t.integer  "navable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden_teaser_box"
    t.index ["navable_id", "navable_type"], name: "navable_type", using: :btree
  end

  create_table "navable_visits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "navable_id"
    t.string   "navable_type"
    t.integer  "group_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "recipient_id"
    t.integer  "author_id"
    t.string   "reference_url"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.string   "message"
    t.text     "text",           limit: 65535
    t.datetime "sent_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "read_at"
    t.datetime "failed_at"
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.text     "content",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "redirect_to"
    t.integer  "author_user_id"
    t.string   "type"
    t.datetime "archived_at"
    t.text     "box_configuration", limit: 65535
    t.text     "teaser_text",       limit: 65535
    t.datetime "published_at"
    t.boolean  "embedded"
    t.string   "domain"
    t.string   "locale"
    t.index ["author_user_id"], name: "pages_author_user_id_fk", using: :btree
  end

  create_table "permalinks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "url_path"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "host"
  end

  create_table "post_deliveries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.string   "user_email"
    t.datetime "sent_at"
    t.datetime "failed_at"
    t.string   "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "subject"
    t.text     "text",                      limit: 65535
    t.integer  "group_id"
    t.integer  "author_user_id"
    t.string   "external_author"
    t.datetime "sent_at"
    t.boolean  "sticky"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "entire_message",            limit: 65535
    t.string   "message_id"
    t.string   "content_type"
    t.string   "sent_via"
    t.datetime "published_at"
    t.boolean  "publish_on_public_website"
    t.index ["author_user_id"], name: "posts_author_user_id_fk", using: :btree
    t.index ["group_id"], name: "posts_group_id_fk", using: :btree
  end

  create_table "profile_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "profileable_id"
    t.string   "label"
    t.string   "type"
    t.text     "value",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profileable_type"
    t.integer  "parent_id"
    t.index ["parent_id"], name: "profile_fields_parent_id_fk", using: :btree
    t.index ["profileable_id", "profileable_type", "type"], name: "profileable_type", using: :btree
    t.index ["profileable_id", "profileable_type"], name: "profileable", using: :btree
    t.index ["type"], name: "type", using: :btree
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "relationships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user1_id"], name: "relationships_user1_id_fk", using: :btree
    t.index ["user2_id"], name: "relationships_user2_id_fk", using: :btree
  end

  create_table "requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "ip"
    t.string   "method"
    t.string   "request_url"
    t.string   "referer"
    t.integer  "navable_id"
    t.string   "navable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "sashes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semester_calendars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "term_id"
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "var",                      null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id"
    t.string   "thing_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.integer  "author_user_id"
    t.integer  "reference_id"
    t.string   "reference_type"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "comment",        limit: 65535
  end

  create_table "status_group_membership_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "membership_id"
    t.integer  "promoted_by_workflow_id"
    t.integer  "promoted_on_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string  "name",                                     collation: "utf8_bin"
    t.integer "taggings_count",               default: 0
    t.string  "title"
    t.text    "body",           limit: 65535
    t.string  "subtitle"
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "term_report_member_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id"
    t.integer  "term_report_id"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "name_affix"
    t.string   "date_of_birth"
    t.string   "primary_address"
    t.string   "secondary_address"
    t.string   "phone"
    t.string   "email"
    t.string   "profession"
    t.string   "category"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "term_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "term_id"
    t.integer  "group_id"
    t.integer  "number_of_members"
    t.integer  "number_of_new_members"
    t.integer  "number_of_membership_ends"
    t.integer  "number_of_deaths"
    t.integer  "number_of_events"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "balance"
    t.string   "type"
    t.integer  "number_of_status_changes"
    t.integer  "number_of_good_events"
    t.integer  "number_of_events_with_pictures"
    t.integer  "number_of_semester_calendars"
    t.integer  "number_of_semester_calendar_pdfs"
    t.integer  "number_of_current_officers"
    t.integer  "number_of_documents"
    t.integer  "number_of_good_member_profiles"
    t.integer  "number_of_current_member_profiles"
    t.decimal  "score",                             precision: 10
  end

  create_table "terms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type"
  end

  create_table "user_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "encrypted_password",                   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "auth_token"
    t.text     "tokens",                 limit: 65535
    t.text     "provider",               limit: 65535
    t.text     "uid",                    limit: 65535
    t.index ["reset_password_token"], name: "index_user_accounts_on_reset_password_token", unique: true, using: :btree
    t.index ["user_id"], name: "user_accounts_user_id_fk", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "alias"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "female"
    t.string   "accepted_terms"
    t.datetime "accepted_terms_at"
    t.boolean  "incognito"
    t.string   "avatar_id"
    t.string   "notification_policy"
    t.string   "locale"
    t.integer  "sash_id"
    t.integer  "level",               default: 0
  end

  create_table "workflow_kit_parameters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "key"
    t.string   "value"
    t.string   "parameterable_type"
    t.integer  "parameterable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_kit_steps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "sequence_index"
    t.integer  "workflow_id"
    t.string   "brick_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["workflow_id"], name: "workflow_kit_steps_workflow_id_fk", using: :btree
  end

  create_table "workflow_kit_workflows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "attachments", "users", column: "author_user_id", name: "attachments_author_user_id_fk"
  add_foreign_key "bookmarks", "users", name: "bookmarks_user_id_fk"
  add_foreign_key "last_seen_activities", "users", name: "last_seen_activities_user_id_fk"
  add_foreign_key "pages", "users", column: "author_user_id", name: "pages_author_user_id_fk"
  add_foreign_key "posts", "groups", name: "posts_group_id_fk"
  add_foreign_key "posts", "users", column: "author_user_id", name: "posts_author_user_id_fk"
  add_foreign_key "profile_fields", "profile_fields", column: "parent_id", name: "profile_fields_parent_id_fk"
  add_foreign_key "relationships", "users", column: "user1_id", name: "relationships_user1_id_fk"
  add_foreign_key "relationships", "users", column: "user2_id", name: "relationships_user2_id_fk"
  add_foreign_key "user_accounts", "users", name: "user_accounts_user_id_fk"
  add_foreign_key "workflow_kit_steps", "workflow_kit_workflows", column: "workflow_id", name: "workflow_kit_steps_workflow_id_fk"
end
