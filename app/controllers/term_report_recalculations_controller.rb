class TermReportRecalculationsController < TermReportsController

  # POST /term_reports/123/recalculate
  #
  def create
    authorize! :recalculate, term_report

    term_report.fill_info

    redirect_to term_report_path(term_report)
  end

end