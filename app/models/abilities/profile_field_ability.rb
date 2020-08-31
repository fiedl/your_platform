class Abilities::ProfileFieldAbility < Abilities::BaseAbility

  def rights_for_signed_in_users
    can :update, ProfileField, key: 'klammerung', profilable_type: 'User', profileable: { id: user.id }
  end

  def rights_for_local_admins
    if not read_only_mode?
      can :create, ProfileField
      can [:update, :destroy], ProfileField, profileable_type: 'User', profileable: { admins_of_ancestor_groups: { id: user.id } }
      can [:update, :destroy], ProfileField, profileable_type: 'Group', profileable: { admins_of_self_and_ancestors: { id: user.id } }
      cannot [:update, :destroy], ProfileField, key: "W-Nummer"
    end
  end

end