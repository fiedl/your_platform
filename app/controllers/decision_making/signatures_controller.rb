module DecisionMaking
  class SignaturesController < ApplicationController

    expose :signable, -> { (DecisionMaking::Process.find(params[:ballot_id]) if params[:ballot_id]) }

    def new
      authorize! :sign, signable

      set_current_title t(:sign_str, str: signable.title)
      set_current_breadcrumbs [
        {title: Page.root.title, path: public_root_path},
        {title: Page.intranet_root.title, path: root_path},
        {title: t(:federal_ballots), path: decision_making_federal_ballots_path},
        {title: signable.title, path: decision_making_federal_ballot_path(signable)},
        {title: t(:sign)}
      ]
    end

    def create
      authorize! :sign, signable

      if current_user.account.valid_password?(params[:password])
        signable.signatures.create! user_id: current_user.id, verified_by: :password
        redirect_to signable
      else
        flash[:error] = t(:could_not_sign_document_because_of_wrong_password)
        redirect_to :back
      end

    end

  end
end