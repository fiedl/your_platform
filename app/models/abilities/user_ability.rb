class Abilities::UserAbility < Abilities::BaseAbility

  def rights_for_everyone
    can :read_public_bio, User
  end

  def rights_for_signed_in_users
    can [:read, :index_events], User, id: user.id
    can :autocomplete_title, User

    can :read, User, User.wingolfiten.alive do |u|
      u.wingolfit? && u.alive?
    end
    can :read_name, User

    if not read_only_mode?
      can [:update, :change_first_name, :change_alias], User, id: user.id
    end
  end

  def rights_for_local_admins
    if not read_only_mode?
      can :create, User
      can [:read, :update, :change_first_name, :change_alias, :change_status, :create_account_for], User, admins_of_ancestor_groups: { id: user.id }
    end
  end

  def rights_for_global_admins
    can :masquerade_as, User do
      # Only global admins that are developers are allowed
      # to masquerade as other users. This is used for debugging.
      user.developer? && user.global_admin?
    end
  end

end