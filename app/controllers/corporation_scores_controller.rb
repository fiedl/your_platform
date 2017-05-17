class CorporationScoresController < ApplicationController

  expose :term, -> { Term.current.first }
  expose :term_reports, -> { term.term_reports }
  expose :corporation_scores, -> { term_reports.where('score > 0').collect { |report| report.becomes(CorporationScore) } }

  def index
    authorize! :index, :corporation_scores

    set_current_title I18n.t(:corporation_scores)
  end

end