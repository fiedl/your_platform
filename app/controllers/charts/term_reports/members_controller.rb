class Charts::TermReports::MembersController < ChartsController

  # GET /charts/term_reports/members/per_corporation_and_term.json
  #
  def per_corporation_and_term
    authorize! :index, :term_reports_charts

    @members_series_for_each_corporation = Corporation.all.sort_by { |corporation|
      - (corporation.term_reports.last.try(:number_of_members) || 0)
    }.collect { |corporation|
      {
        name: corporation.token,
        data: Hash[corporation.term_reports.collect { |term_report| [term_report.term.title, term_report.number_of_members] }]
      }
    }

    render json: @members_series_for_each_corporation.chart_json
  end

end