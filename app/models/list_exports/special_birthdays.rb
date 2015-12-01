module ListExports
  
  # This birthdays list selects only birthdays 70, 75 and >=80.
  #
  class SpecialBirthdays < BirthdayList
    
    def columns
      [
        :next_age,
        :localized_next_birthday,
        :last_name,
        :first_name,
        :name_affix,
        :localized_date_of_birth
      ]
    end
    
    def data
      super.select { |user|
        user.next_age &&
        (
          user.next_age == 70 or
          user.next_age == 75 or
          user.next_age >= 80
        )
      }.sort_by { |user|
        [(1000 - user.next_age).to_s, (user.next_birthday.try(:strftime, "%y-%m-%d") || '')].join(" ")
      }
    end
    
  end
end