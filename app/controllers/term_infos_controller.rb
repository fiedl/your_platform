class TermInfosController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :term, -> {
    if params[:year] && params[:term_type]
      Term.by_year_and_type params[:year], params[:term_type]
    elsif params[:term_id]
      Term.find params[:term_id]
    end
  }
  expose :group
  expose :corporation, -> { group if group.kind_of? Corporation }
  expose :term_info, -> {
    if term && corporation
      TermInfos::ForCorporation.by_corporation_and_term corporation, term
    elsif params[:id]
      TermInfo.find params[:id]
    end
  }

  def show
    authorize! :read, term_info
    set_current_navable term_info.group
    set_current_title term_info.title
  end

end