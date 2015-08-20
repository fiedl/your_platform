module ListExports
  
  # This class produces a birthday list export that looks like this
  # in csv format with German locale:
  #
  #     Nachname;Vorname;Namenszusatz;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter
  #     Doe;Jonathan;\"\";13.11.2015;13.11.1986;28
  #
  class BirthdayList < Base
    
    def columns
      [
        :last_name,
        :first_name,
        :name_affix,
        :localized_birthday_this_year,
        :localized_date_of_birth,
        :current_age
      ]
    end
    
    # Sort the listed users by day of birth.
    #
    def data
      super.sort_by do |user|
        user.date_of_birth.try(:strftime, "%m-%d") || ''
      end
    end
    
  end
end