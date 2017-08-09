class TermReportsController < ApplicationController
  include CurrentTerm

  expose :term_report, -> {
    if params[:id] || params[:term_report_id]
      TermReport.find (params[:id] || params[:term_report_id])
    elsif term && corporation
      TermReports::ForCorporation.by_corporation_and_term corporation, term
    elsif corporation
      TermReports::ForCorporation.by_corporation_and_term corporation, Term.current.first
    end
  }
  expose :termable, -> { term_report }

  def show
    authorize! :read, term_report

    # To make the url unique, redirect to the proper url
    # if the record has been found by the search form submission.
    #
    redirect_to(term_report_path(id: term_report.id)) unless params[:id]

    set_current_title term_report.title
    set_current_breadcrumbs [
      {title: Page.intranet_root.title, path: root_path},
      {title: t(:term_reports), path: term_reports_path},
      {title: term_report.group.name, path: group_members_path(term_report.group)},
      {title: term_report.term.title}
    ]
  end

  expose :term_reports, -> { term.try(:term_reports) || TermReport.all }

  def index
    authorize! :index, TermReport

    set_current_title t :term_reports
  end

  # POST /term_reports/123/submit
  #
  def submit
    authorize! :submit, term_report
    raise "term report #{term_report.id} cannot be submitted because it has already been #{term_report.state.to_s}." if term_report.state
    raise "term report #{term_report.id} is not due." unless term_report.due?
    raise "term report #{term_report.id} is too old to submit." if term_report.too_old_to_submit?

    term_report.states.create name: "submitted", author_user_id: current_user.id

    redirect_to term_report_path(term_report)
  end

end