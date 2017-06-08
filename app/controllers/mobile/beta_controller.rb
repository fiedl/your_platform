class Mobile::BetaController < Mobile::BaseController

  expose :my_invitation, -> { beta.invitations.where(invitee_id: current_user.id ).first }
  expose :invitations_sent_by_me, -> { beta.invitations.where(inviter_id: current_user.id) }

  def show
    authorize! :read, :mobile_dashboard

    set_current_title "Vademecum-Beta"
  end

end