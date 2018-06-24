class TermReportSubmissionsController < TermReportsController

  # POST /term_reports/123/submit
  #
  def create
    authorize! :submit, term_report
    raise ActionController::BadRequest, "term report #{term_report.id} cannot be submitted because it has already been accepted." if term_report.accepted?
    raise ActionController::BadRequest, "term report #{term_report.id} cannot be submitted because it has already been submitted." if term_report.submitted? && (term_report.submitted_at > term_report.rejected_at)
    raise ActionController::BadRequest, "term report #{term_report.id} is not due." unless term_report.due?
    raise ActionController::BadRequest, "term report #{term_report.id} is too old to submit." if term_report.too_old_to_submit?

    term_report.states.create name: "submitted", author_user_id: current_user.id

    redirect_to term_report_path(term_report)
  end

end