class BetaInvitationsController < ApplicationController

  expose :beta
  expose :beta_invitations, -> { beta.invitations }

  def index
    authorize! :index, :beta_invitations

    set_current_title "Invitations for beta #{beta.title}"
  end

  def create
    authorize! :create_beta_invitation_for, beta

    @beta_invitation = BetaInvitation.new(beta_invitation_params)
    @beta_invitation.inviter = current_user
    @beta_invitation.invitee_title = beta_invitation_params[:invitee_title]

    if not @beta_invitation.beta.invitees.include?(@beta_invitation.invitee)
      @beta_invitation.save
      @beta_invitation.send_notification_later
    end

    redirect_to :back
  end

  private

  def beta_invitation_params
    params.require(:beta_invitation).permit(:beta_id, :invitee_id, :invitee_title)
  end

end