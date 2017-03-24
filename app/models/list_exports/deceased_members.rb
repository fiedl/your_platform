module ListExports

  # This class produces a list export for deceased members that looks like this
  # in csv format with German locale:
  #
  #     Nachname;Vorname;Namenszusatz;Persönlicher Titel;Geburtsdatum;Sterbedatum;Wohnort
  #     Doe;Jonathan;\"\";Dipl.-Ing.;13.11.1916;12.01.2016;Musterstadt
  #
  class DeceasedMembers < Base

    def columns
      [
        :last_name,
        :first_name,
        :name_affix_without_deceased_symbol,
        :personal_title,
        :localized_date_of_birth,
        :localized_date_of_death,
        :age_at_date_of_death,
        :postal_address_town
      ]
    end

    # Sort the listed users by date of death reversed.
    #
    def data
      super.select { |user|
        user.date_of_death && (user.date_of_death.to_date >= 1.year.ago)
      }.sort_by { |user|
        user.date_of_death.to_date
      }.reverse
    end

  end
end