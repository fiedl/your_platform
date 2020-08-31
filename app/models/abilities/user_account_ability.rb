class Abilities::UserAccountAbility < Abilities::BaseAbility

  def rights_for_local_admins
    can :manage, UserAccount, user: { admins_of_ancestor_groups: { id: user.id } }
  end

end