class Charts::TermInfos::MembersController < ChartsController

  # GET /charts/term_infos/members/per_corporation_and_term.json
  #
  def per_corporation_and_term
    authorize! :index, :term_infos_charts

    @members_series_for_each_corporation = Corporation.all.sort_by { |corporation|
      - (corporation.term_infos.last.try(:number_of_members) || 0)
    }.collect { |corporation|
      {
        name: corporation.token,
        data: Hash[corporation.term_infos.collect { |term_info| [term_info.term.title, term_info.number_of_members] }]
      }
    }

    render json: @members_series_for_each_corporation.chart_json
  end

end