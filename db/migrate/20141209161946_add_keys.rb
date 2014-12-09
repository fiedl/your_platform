class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "attachments", "users", name: "attachments_author_user_id_fk", column: "author_user_id"
    add_foreign_key "bookmarks", "users", name: "bookmarks_user_id_fk"
#    add_foreign_key "dag_links", "groups", name: "dag_links_ancestor_id_fk", column: "ancestor_id"
#    add_foreign_key "dag_links", "users", name: "dag_links_descendant_id_fk", column: "descendant_id"
    add_foreign_key "last_seen_activities", "users", name: "last_seen_activities_user_id_fk"
    add_foreign_key "pages", "users", name: "pages_author_user_id_fk", column: "author_user_id"
    add_foreign_key "posts", "users", name: "posts_author_user_id_fk", column: "author_user_id"
    add_foreign_key "posts", "groups", name: "posts_group_id_fk"
    add_foreign_key "profile_fields", "profile_fields", name: "profile_fields_parent_id_fk", column: "parent_id"
    add_foreign_key "relationships", "users", name: "relationships_user1_id_fk", column: "user1_id"
    add_foreign_key "relationships", "users", name: "relationships_user2_id_fk", column: "user2_id"
#    add_foreign_key "status_group_membership_infos", "dag_links", name: "status_group_membership_infos_membership_id_fk", column: "membership_id"
#    add_foreign_key "status_group_membership_infos", "workflow_kit_workflows", name: "status_group_membership_infos_promoted_by_workflow_id_fk", column: "promoted_by_workflow_id"
#    add_foreign_key "status_group_membership_infos", "events", name: "status_group_membership_infos_promoted_on_event_id_fk", column: "promoted_on_event_id"
    add_foreign_key "user_accounts", "users", name: "user_accounts_user_id_fk"
    add_foreign_key "workflow_kit_steps", "workflow_kit_workflows", name: "workflow_kit_steps_workflow_id_fk", column: "workflow_id"
  end
end
