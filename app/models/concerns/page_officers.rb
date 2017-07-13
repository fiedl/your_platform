concern :PageOfficers do

  def number_of_officers_to_show
    if settings.show_only_the_first_n_offices
      settings.show_only_the_first_n_offices.try(:to_i) || 1
    end
  end

end