module ListExports
  
  # This class produces simple name list export with some basic information that looks like this
  # in csv format with German locale:
  #
  #     Nachname;Vorname;Namenszusatz;Persönlicher Titel;Akademischer Grad;Mitglied in 'Gruppe XY' seit
  #     Doe;Jonathan;\"\";Dr.;Dr. rer. nat.;12.12.1987
  #
  class NameList < Base
    
    def columns
      [
        :last_name,
        :first_name,
        :name_affix,
        :personal_title,
        :academic_degree,
        :member_since
      ]
    end
    
    # Sort the listed users last name and first name.
    # Also, add the date of joining.
    #
    def data
      super.collect { |user|
        user = user.becomes(ListExportUser)
        user.member_since = I18n.localize(user.date_of_joining(group))
        user
      }.sort_by { |user|
        user.last_name + user.first_name
      }
    end
    
    # Don't just write "Member since". Write "Member of 'group xyz' since".
    #
    def headers
      super.collect do |header|
        if header == I18n.t(:member_since)
          I18n.t(:member_of_str_since, str: group.title)
        else
          header
        end
      end
    end
    
  end
end