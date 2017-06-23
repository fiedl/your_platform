module DecisionMaking
  class FederalBallotsController < ApplicationController

    expose :federal_ballots, -> { FederalBallot.all }
    expose :federal_ballot, -> { FederalBallot.find params[:id] if params[:id] }

    def index
      authorize! :index, FederalBallot
      set_current_title t(:federal_ballots)
    end

    def show
      authorize! :read, federal_ballot
      set_current_title federal_ballot.title
      set_current_breadcrumbs [
        {title: Page.root.title, path: public_root_path},
        {title: Page.intranet_root.title, path: root_path},
        {title: t(:federal_ballots), path: decision_making_federal_ballots_path},
        {title: current_title}
      ]
    end

    def create
      authorize! :create, FederalBallot

      @federal_ballot = FederalBallot.create creator_user_id: current_user.id, title: t(:new_federal_ballot)
      redirect_to @federal_ballot
    end

    def update
      authorize! :update, federal_ballot
      federal_ballot.update_attributes(federal_ballot_params)
      respond_with_bip federal_ballot
    end

    def destroy
      authorize! :destroy, federal_ballot
      federal_ballot.destroy!
      redirect_to decision_making_federal_ballots_path
    end

    private

    def federal_ballot_params
      params.require(:decision_making_federal_ballot).permit(:title, :wording, :rationale, :deadline, :localized_proposed_at, :proposer_group_id)
    end

  end
end