class Abilities::GroupAbility < Abilities::BaseAbility

  def rights_for_everyone
    can :index_events, Group
  end

  def rights_for_signed_in_users
    can :index, Group
    can :show, Group

    # List exports
    #   - BV-Mitgliedschaft berechtigt dazu, die Mitglieder dieses BV
    #       zu exportieren.
    #   - Mitgliedschaft in einer Verbindung als Bursch oder Philister
    #       berechtigt dazu, die Mitglieder dieser Verbindung zu
    #       exportieren.
    #   - Normale Gruppen-Mitgliedschaften (etwa Gruppe 'Jeder'
    #       oder 'Wingolfsblätter-Abonnenten') berechtigen nicht zum
    #       Export.
    #
    can :export_member_list, Group, type: 'Bv', members: { id: user.id }
    can :export_member_list, Group, corporation: { philisterschaft: { members: { id: user.id } } }
    can :export_member_list, Group, corporation: { burschia: { members: { id: user.id } } }

  end

  def rights_for_local_officers
    can [:export_member_list, :export_calendar_feed_url_for_local_homepage], Group, officers_of_self_and_ancestors: { id: user.id }

    if not read_only_mode?
      can [:create_event, :create_event_for, :create_page_for], Group, officers_of_self_and_ancestors: { id: user.id }
    end
  end

  def rights_for_local_admins
    can [:export_stammdaten_for], Group, admins_of_self_and_ancestors: { id: user.id }

    if not read_only_mode?
      #can :manage, Group, admins_of_self_and_ancestors: { id: user.id }

      can [:update, :change_internal_token, :update_members, :update_memberships, :create_group_for, :add_group_member, :index_memberships, :create_memberships, :create_officer_group_for, :manage_mailing_lists, :manage_mailing_lists_for, :manage_settings], Group, admins_of_self_and_ancestors: { id: user.id }

      # A local officer can only rename certain groups.
      # He cannot rename groups with flags.
      # And he cannot, for example, rename corporations.
      # When using scopes, an additional block is required in cancan.
      # When using a conditions hash, a block is not needed.
      #
      can :rename, Group, admins_of_self_and_ancestors: { id: user.id }, type: [nil, "StatusGroup", "Groups::Wohnheimsverein", "OfficerGroup"]
      # #cannot :rename, Group, -> { Group.has_flags } do |group|
      # #  group.flags.any?
      # #end
      #
      # can :destroy, Group, admins_of_self_and_ancestors: { id: user.id }
      # #cannot :destroy, Group, Group.has_flags do |group|
      # #  group.flags.any?
      # #end
      # #cannot :destory, Group, Group.has_descendant_users do |group|
      # #  group.descendant_users.any?
      # #end
    end
  end

  def rights_for_global_admins
    if not read_only_mode?
      can :add_group_member_manually, Group
    end
  end

end