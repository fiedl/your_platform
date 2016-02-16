module ListExports
  
  # This class produces simple name list export with some basic information that looks like this
  # in csv format with German locale:
  #
  #     Nachname;Vorname;Namenszusatz;Persönlicher Titel;Akademischer Grad
  #     Doe;Jonathan;\"\";Dr.;Dr. rer. nat.
  #
  class NameList < Base
    
    def columns
      [
        :last_name,
        :first_name,
        :name_affix,
        :personal_title,
        :academic_degree
      ]
    end
    
    # Sort the listed users last name and first name.
    #
    def data
      super.sort_by do |user|
        user.last_name + user.first_name
      end
    end
    
  end
end