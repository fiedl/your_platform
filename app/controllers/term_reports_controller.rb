class TermReportsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :term, -> {
    if params[:year] && params[:term_type]
      Term.by_year_and_type params[:year], params[:term_type]
    elsif params[:term_id]
      Term.find params[:term_id]
    end
  }
  expose :group, -> {
    if params[:group_id]
      Group.find params[:group_id]
    else
      term_report.group
    end
  }
  expose :corporation, -> { group if group.kind_of? Corporation }
  expose :term_report, -> {
    if term && corporation
      TermReports::ForCorporation.by_corporation_and_term corporation, term
    elsif params[:id]
      TermReport.find params[:id]
    end
  }

  def show
    authorize! :read, term_report

    # To make the url unique, redirect to the proper url
    # if the record has been found by the search form submission.
    #
    redirect_to(term_report_path(id: term_report.id)) unless params[:id]

    set_current_navable term_report.group
    set_current_title term_report.title
  end

end