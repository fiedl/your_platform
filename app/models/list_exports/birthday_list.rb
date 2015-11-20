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
        :localized_date_of_birth,
        :localized_next_birthday,
        :next_age
      ]
    end
    
    # Sort the listed users by day of birth.
    #
    def data
      super.select { |user|
        case @options[:quater]
        when nil, ''
          true
        when '1'
          user.date_of_birth && user.date_of_birth.month.in?([1, 2, 3])
        when '2'
          user.date_of_birth && user.date_of_birth.month.in?([4, 5, 6])
        when '3'
          user.date_of_birth && user.date_of_birth.month.in?([7, 8, 9])
        when '4'
          user.date_of_birth && user.date_of_birth.month.in?([10, 11, 12])
        end
      }.sort_by { |user|
        user.next_birthday.try(:strftime, "%y-%m-%d") || ''
      }
    end
    
  end
end