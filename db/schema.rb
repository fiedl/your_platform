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

ActiveRecord::Schema.define(version: 2020_11_26_135638) do

  create_table "activities", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "trackable_type"
    t.integer "trackable_id"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "attachments", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "file"
    t.string "title"
    t.text "description"
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "content_type"
    t.integer "file_size"
    t.integer "author_user_id"
    t.integer "width"
    t.integer "height"
    t.string "type"
    t.index ["author_user_id"], name: "attachments_author_user_id_fk"
  end

  create_table "auth_tokens", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "token"
    t.integer "user_id"
    t.string "resource_type"
    t.integer "resource_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_auth_tokens_on_token", unique: true
  end

  create_table "badges_sashes", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "sash_id"
    t.boolean "notified_user", default: false
    t.datetime "created_at"
    t.index ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id"
    t.index ["badge_id"], name: "index_badges_sashes_on_badge_id"
    t.index ["sash_id"], name: "index_badges_sashes_on_sash_id"
  end

  create_table "beta_invitations", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "beta_id"
    t.integer "inviter_id"
    t.integer "invitee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "betas", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.integer "max_invitations_per_inviter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "key"
  end

  create_table "bookmarks", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "bookmarkable_id"
    t.string "bookmarkable_type"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "bookmarks_user_id_fk"
  end

  create_table "bv_mappings", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "bv_name"
    t.string "plz"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "town"
  end

  create_table "comments", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.text "text"
    t.integer "author_user_id"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dag_links", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "ancestor_id"
    t.string "ancestor_type"
    t.integer "descendant_id"
    t.string "descendant_type"
    t.boolean "direct"
    t.integer "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_to", precision: 6
    t.datetime "valid_from", precision: 6
    t.string "type"
    t.index ["ancestor_id", "ancestor_type", "direct"], name: "dag_ancestor"
    t.index ["descendant_id", "descendant_type"], name: "dag_descendant"
  end

  create_table "decision_making_options", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "process_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_making_processes", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.string "type"
    t.text "wording"
    t.text "rationale"
    t.integer "proposer_group_id"
    t.integer "scope_group_id"
    t.integer "creator_user_id"
    t.string "required_majority"
    t.datetime "proposed_at"
    t.datetime "opened_for_voting_at"
    t.datetime "deadline"
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_making_signatures", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.string "signable_type"
    t.string "signable_id"
    t.string "verified_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_making_votes", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "process_id"
    t.integer "option_id"
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location"
    t.boolean "publish_on_global_website"
    t.boolean "publish_on_local_website"
    t.integer "group_id"
  end

  create_table "flags", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "key"
    t.integer "flagable_id"
    t.string "flagable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["flagable_id", "flagable_type", "key"], name: "flagable_key"
    t.index ["flagable_id", "flagable_type"], name: "flagable"
    t.index ["key"], name: "key"
  end

  create_table "geo_locations", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "country"
    t.string "country_code"
    t.string "city"
    t.string "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "queried_at"
    t.string "street"
    t.string "state"
    t.index ["address"], name: "index_geo_locations_on_address"
  end

  create_table "groups", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "token"
    t.string "extensive_name"
    t.string "internal_token"
    t.text "body"
    t.string "type"
    t.string "mailing_list_sender_filter"
    t.string "subdomain"
  end

  create_table "impressions", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message"
    t.text "referrer"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { params: 255 }
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { message: 255 }
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "issues", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "reference_id"
    t.string "reference_type"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "responsible_admin_id"
    t.integer "author_id"
  end

  create_table "last_seen_activities", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.string "description"
    t.integer "link_to_object_id"
    t.string "link_to_object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "last_seen_activities_user_id_fk"
  end

  create_table "locations", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "object_id"
    t.string "object_type"
    t.float "longitude"
    t.float "latitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "magazines", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "group_id"
    t.integer "editors_group_id"
    t.integer "subscribers_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mentions", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "who_user_id"
    t.integer "whom_user_id"
    t.string "reference_type"
    t.integer "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["whom_user_id"], name: "index_mentions_on_whom_user_id"
  end

  create_table "merit_actions", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.string "action_method"
    t.integer "action_value"
    t.boolean "had_errors", default: false
    t.string "target_model"
    t.integer "target_id"
    t.text "target_data"
    t.boolean "processed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merit_activity_logs", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "action_id"
    t.string "related_change_type"
    t.integer "related_change_id"
    t.string "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "score_id"
    t.integer "num_points", default: 0
    t.string "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "sash_id"
    t.string "category", default: "default"
  end

  create_table "nav_nodes", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "url_component"
    t.string "breadcrumb_item"
    t.string "menu_item"
    t.boolean "slim_breadcrumb"
    t.boolean "slim_url"
    t.boolean "slim_menu"
    t.boolean "hidden_menu"
    t.string "navable_type"
    t.integer "navable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "hidden_teaser_box"
    t.index ["navable_id", "navable_type"], name: "navable_type"
  end

  create_table "navable_visits", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "navable_id"
    t.string "navable_type"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "author_id"
    t.string "reference_url"
    t.string "reference_type"
    t.integer "reference_id"
    t.string "message"
    t.text "text"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.datetime "failed_at"
  end

  create_table "pages", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "redirect_to"
    t.integer "author_user_id"
    t.string "type"
    t.datetime "archived_at"
    t.text "box_configuration"
    t.text "teaser_text"
    t.datetime "published_at"
    t.boolean "embedded"
    t.string "domain"
    t.string "locale"
    t.index ["author_user_id"], name: "pages_author_user_id_fk"
  end

  create_table "permalinks", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "url_path"
    t.string "reference_type"
    t.integer "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "host"
  end

  create_table "post_deliveries", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "post_id"
    t.integer "user_id"
    t.string "user_email"
    t.datetime "sent_at"
    t.datetime "failed_at"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "subject"
    t.text "text"
    t.integer "group_id"
    t.integer "author_user_id"
    t.string "external_author"
    t.datetime "sent_at"
    t.boolean "sticky"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "entire_message"
    t.string "message_id"
    t.string "content_type"
    t.string "sent_via"
    t.datetime "published_at"
    t.boolean "publish_on_public_website"
    t.datetime "archived_at"
    t.index ["author_user_id"], name: "posts_author_user_id_fk"
    t.index ["group_id"], name: "posts_group_id_fk"
  end

  create_table "profile_fields", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "profileable_id"
    t.string "label"
    t.string "type"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "profileable_type"
    t.integer "parent_id"
    t.index ["parent_id"], name: "profile_fields_parent_id_fk"
    t.index ["profileable_id", "profileable_type", "type"], name: "profileable_type"
    t.index ["profileable_id", "profileable_type"], name: "profileable"
    t.index ["type"], name: "type"
  end

  create_table "projects", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relationships", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "user1_id"
    t.integer "user2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user1_id"], name: "relationships_user1_id_fk"
    t.index ["user2_id"], name: "relationships_user2_id_fk"
  end

  create_table "requests", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.string "ip"
    t.string "method"
    t.string "request_url"
    t.string "referer"
    t.integer "navable_id"
    t.string "navable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sashes", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semester_calendars", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "term_id"
  end

  create_table "settings", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "states", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "author_user_id"
    t.integer "reference_id"
    t.string "reference_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
  end

  create_table "status_group_membership_infos", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "membership_id"
    t.integer "promoted_by_workflow_id"
    t.integer "promoted_on_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.string "title"
    t.text "body"
    t.string "subtitle"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "term_report_member_entries", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.integer "term_report_id"
    t.string "last_name"
    t.string "first_name"
    t.string "name_affix"
    t.string "date_of_birth"
    t.string "primary_address"
    t.string "secondary_address"
    t.string "phone"
    t.string "email"
    t.string "profession"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "klammerung"
    t.string "w_nummer"
    t.float "membership_fee_factor"
  end

  create_table "term_reports", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "term_id"
    t.integer "group_id"
    t.integer "number_of_members"
    t.integer "number_of_new_members"
    t.integer "number_of_membership_ends"
    t.integer "number_of_deaths"
    t.integer "number_of_events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "anzahl_aktivmeldungen"
    t.integer "anzahl_aller_aktiven"
    t.integer "anzahl_burschungen"
    t.integer "anzahl_burschen"
    t.integer "anzahl_fuxen"
    t.integer "anzahl_aktiver_burschen"
    t.integer "anzahl_inaktiver_burschen_loci"
    t.integer "anzahl_inaktiver_burschen_non_loci"
    t.integer "anzahl_konkneipwanten"
    t.integer "anzahl_philistrationen"
    t.integer "anzahl_philister"
    t.integer "anzahl_austritte"
    t.integer "anzahl_austritte_aktive"
    t.integer "anzahl_austritte_philister"
    t.integer "anzahl_todesfaelle"
    t.integer "balance"
    t.string "type"
    t.integer "anzahl_erstbandtraeger_aktivitas"
    t.integer "anzahl_erstbandtraeger_philisterschaft"
    t.integer "number_of_status_changes"
    t.integer "number_of_good_events"
    t.integer "number_of_events_with_pictures"
    t.integer "number_of_semester_calendars"
    t.integer "number_of_semester_calendar_pdfs"
    t.integer "number_of_current_officers"
    t.integer "number_of_documents"
    t.integer "number_of_good_member_profiles"
    t.integer "number_of_current_member_profiles"
    t.decimal "score", precision: 10
  end

  create_table "terms", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
  end

  create_table "user_accounts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "auth_token"
    t.text "tokens"
    t.text "provider"
    t.text "uid"
    t.index ["reset_password_token"], name: "index_user_accounts_on_reset_password_token", unique: true
    t.index ["user_id"], name: "user_accounts_user_id_fk"
  end

  create_table "users", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "alias"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "female"
    t.string "accepted_terms"
    t.datetime "accepted_terms_at"
    t.boolean "incognito"
    t.string "avatar_id"
    t.string "notification_policy"
    t.string "locale"
    t.integer "sash_id"
    t.integer "level", default: 0
  end

  create_table "workflow_kit_parameters", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.string "parameterable_type"
    t.integer "parameterable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_kit_steps", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "sequence_index"
    t.integer "workflow_id"
    t.string "brick_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["workflow_id"], name: "workflow_kit_steps_workflow_id_fk"
  end

  create_table "workflow_kit_workflows", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflows", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
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
