concern :PageOfficers do

  def number_of_officers_to_show
    if settings.show_only_the_first_n_offices
      settings.show_only_the_first_n_offices.try(:to_i) || 1
    end
  end

  def show_officers_for_group_id
    settings.show_officers_for_group_id
  end

  def show_officers_for_group_id=(new_group_id)
    settings.show_officers_for_group_id = new_group_id
  end

end