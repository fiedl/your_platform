class TermInfos::ChartsController < ApplicationController

  def index
    authorize! :index, :term_infos_charts

    set_current_title "Semester-Info-Diagramme"
  end

  def members_per_corporation_and_term
    authorize! :index, :term_infos_charts

    @members_series_for_each_corporation = Corporation.all.sort_by { |corporation|
      - (corporation.term_infos.last.try(:number_of_members) || 0)
    }.collect { |corporation|
      {
        name: corporation.token,
        data: Hash[corporation.term_infos.collect { |term_info| [term_info.term.title, term_info.number_of_members] }]
      }
    }
    #} + [{
    #  name: "Alle Wingolfiten",
    #  data: Hash[Term.all.collect { |term| [term.title, TermInfos::AlleWingolfiten.for_term(term).number_of_members] }]
    #}]

    render json: @members_series_for_each_corporation.chart_json
  end

end