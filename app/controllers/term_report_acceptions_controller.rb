class TermReportAcceptionsController < TermReportsController

  # POST /term_reports/123/accept?accept=true
  # POST /term_reports/123/accept?reject=true
  #
  def create
    raise ActionController::BadRequest, "term report #{term_report.id} is not yet submitted." unless term_report.submitted?

    accept if params[:accept]
    reject if params[:reject]

    redirect_to term_report_path(term_report)
  end

  private

  def accept
    authorize! :accept, term_report

    term_report.states.create name: "accepted", author_user_id: current_user.id, comment: params[:state_comment]
  end

  def reject
    authorize! :reject, term_report

    term_report.states.create name: "rejected", author_user_id: current_user.id, comment: params[:state_comment]
  end

end