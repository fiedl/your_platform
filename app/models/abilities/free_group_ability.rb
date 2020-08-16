class Abilities::FreeGroupAbility < Abilities::BaseAbility

  def rights_for_signed_in_users
    if not read_only_mode?
      can [:index, :read, :create], Groups::FreeGroup
    end
  end

  def rights_for_local_officers
    if not read_only_mode?
      can [:update], Groups::FreeGroup, officers: {id: user.id}
      can [:destroy], Groups::FreeGroup, officers: {id: user.id}, members: {id: nil}
    end
  end

  def rights_for_global_admins
    can :manage, Groups::FreeGroup
  end

end