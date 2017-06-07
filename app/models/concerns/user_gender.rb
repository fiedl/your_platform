concern :UserGender do

  # Currently, the `female` column of ther `User` model is boolean.
  # Probably, we'll migrate to a `gender` string field later.
  #
  # In addition to this colum, we try to detect the gender
  # using the first name.
  #
  def female?
    @female ||= super || first_name_suggests_female?
  end

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

  # Using the gender_detector gem, estimate the gender from the first name.
  # https://trello.com/c/dbUilD00/1140-genderdetector
  #
  def gender_from_first_name
    GenderDetector.new.get_gender(first_name)
  end
  def first_name_suggests_female?
    gender_from_first_name == :female
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