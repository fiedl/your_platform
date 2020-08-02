class Abilities::CorporationAbility < Abilities::BaseAbility
  # As Corporations are Groups, the `Abilities::CorporationAbility`
  # does also apply.

  def rights_for_local_officers
    can :update_accommodations, Corporation, officers: { id: user.id }

  end
end