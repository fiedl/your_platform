concern :UserCaching do

  # Please make sure this concern is included at the bottom
  # of the class. Otherwiese, the methods referred to here
  # are not defined, yet.
  #
  included do
    after_save { self.delay.renew_cache }

    cache :date_of_death
    cache :name_with_surrounding
    cache :address_label
    cache :current_corporations
    cache :sorted_current_corporations
    cache :my_groups_in_first_corporation
    cache :status_group_in_primary_corporation
    cache :status_export_string
    cache :hidden

    # UserDateOfBirth
    cache :date_of_birth
    cache :age
    cache :birthday_this_year

    cache :group_ids_by_category

    # UserRoles
    cache :admin_of_anything?
    cache :former_member?
    cache :localized_date_of_org_membership_end
    cache :developer?
    cache :beta_tester?
    cache :global_admin?
    cache :global_officer?
  end

  # # Aparently, the `StructureableMixins::Roles` don't work correctly
  # # for users, yet. Thus, it's harmful to try to cache those methods,
  # # because they create lots of errors on `fill_cache`.
  # #
  # # TODO: Fix `StructureableMixins::Roles` before including the
  # # `StructureableRoleCaching`.
  # #
  # include StructureableRoleCaching
end