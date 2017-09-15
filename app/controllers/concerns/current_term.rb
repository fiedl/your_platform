concern :CurrentTerm do

  included do

    # https://railscasts.com/episodes/259-decent-exposure
    #
    expose :term, -> {
      if params[:year] && params[:term_type]
        Term.by_year_and_type params[:year], params[:term_type]
      elsif params[:term_id]
        Term.find params[:term_id]
      elsif params[:id]
        termable.term
      else
        Term.first_or_create_current
      end
    }

    expose :group, -> {
      if params[:group_id]
        Group.find params[:group_id]
      elsif params[:id] || (params[:year] && params[:term_type] && action_name.in?(["show", "update", "destroy"]))
        termable.group
      end
    }

    expose :corporation, -> { group if group.kind_of? Corporation }
  end

end