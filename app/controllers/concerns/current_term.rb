concern :CurrentTerm do

  included do

    # https://railscasts.com/episodes/259-decent-exposure
    #
    expose :term, -> {
      if params[:year].present? && params[:term_type].present?
        Term.by_year_and_type params[:year], params[:term_type]
      elsif params[:term_id]
        Term.find params[:term_id]
      elsif action_name.in?(['show'])
        if params[:id]
          termable.term
        else
          Term.first_or_create_current
        end
      end
    }

    expose :terms, -> {
      if params[:year].present? && params[:term_type].present?
        [term]
      elsif params[:term_id].present?
        [term]
      elsif params[:year].present?
        Term.where(year: params[:year])
      elsif params[:term_type].present?
        Term.where(type: params[:term_type])
      end
    }

    expose :group, -> {
      if params[:group_id].present?
        Group.find params[:group_id]
      elsif params[:id] || (params[:year] && params[:term_type] && action_name.in?(["show", "update", "destroy"]))
        termable.group
      end
    }

    expose :corporation, -> { group if group.kind_of? Corporation }
  end

end