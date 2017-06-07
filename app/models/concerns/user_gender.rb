concern :UserGender do

  # This accessors allow to access the gender of the user rather than just asking if the
  # user is female as allowed by the ActiveRecord accessor.
  # (:female is a boolean column in the users table.)
  #
  def gender
    return :female if female?
    return :male
  end
  def gender=( new_gender )
    if new_gender.to_s == "female"
      self.female = true
    else
      self.female = false
    end
  end
  def male?
    not female?
  end

  # This is the salutation for addess labels, for example:
  #
  #     Mr.
  #     John Doe
  #
  def male_or_female_salutation
    if female?
      if age < 18
        I18n.translate(:to_ms, locale)
      else
        I18n.translate(:to_mrs, locale)
      end
    else
      I18n.translate(:to_mr, locale)
    end
  end

end