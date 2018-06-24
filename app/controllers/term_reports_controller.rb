class TermReportsController < ApplicationController
  include CurrentTerm

  expose :term_report, -> {
    unless action_name.in?(['index'])
      if params[:id] || params[:term_report_id]
        TermReport.find (params[:id] || params[:term_report_id])
      elsif term && corporation
        TermReports::ForCorporation.by_corporation_and_term corporation, term
      elsif corporation
        TermReports::ForCorporation.by_corporation_and_term corporation, Term.current.first
      end
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

  expose :term_reports, -> {
    reports = TermReport.all
    reports = reports.where(group_id: group.id) if group
    reports = reports.where(term_id: terms.pluck(:id)) if terms && terms.any?
    reports
  }

  def index
    authorize! :index, TermReport

    if term && corporation
      redirect_to term_report_path(id: TermReports::ForCorporation.by_corporation_and_term(corporation, term))
    else
      @hide_vertical_nav = true
      if group
        set_current_navable group
      else
        set_current_navable Page.intranet_root
      end
      set_current_title t :term_reports
    end
  end

end