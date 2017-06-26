module DecisionMaking
  class SubmissionsController < ApplicationController

    expose :ballot, -> { (DecisionMaking::Process.find(params[:ballot_id]) if params[:ballot_id]) }

    def create
      authorize! :submit, ballot

      ballot.proposed_at = Time.zone.now
      ballot.save

      ballot.notify_global_officers_about_new_proposal(current_user: current_user)
      redirect_to ballot, notice: t(:ballot_has_been_submitted_to_global_officers)
    end

  end
end