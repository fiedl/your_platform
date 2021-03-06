# This module contains all the methods of a user related to his
# date of birth.
#
concern :UserDateOfBirth do

  included do
    has_one :date_of_birth_profile_field, -> { where label: 'date_of_birth' }, class_name: "ProfileFields::Date", as: :profileable, autosave: true
    after_save :save_date_of_birth_profile_field

    scope :without_birthday, -> { joins(:date_of_birth_profile_field).where(profile_fields: {profileable_id: nil}).or(
      joins(:date_of_birth_profile_field).where(profile_fields: {value: [nil, ""]})
    ) }
    scope :with_birthday, -> { where.not(id: without_birthday) }
  end

  def date_of_birth
    date_of_birth_profile_field.value.to_date if date_of_birth_profile_field.value if date_of_birth_profile_field
  end
  def date_of_birth=( date_of_birth )
    @date_of_birth_will_change = true
    find_or_build_date_of_birth_profile_field.value = date_of_birth
  end

  def date_of_birth_field
    find_or_build_date_of_birth_profile_field
  end
  def find_or_build_date_of_birth_profile_field
    date_of_birth_profile_field || build_date_of_birth_profile_field
  end
  def save_date_of_birth_profile_field
    date_of_birth_profile_field.try(:save) if @date_of_birth_will_change
  end
  private :save_date_of_birth_profile_field

  def find_or_create_date_of_birth_profile_field
    date_of_birth_profile_field || ( build_date_of_birth_profile_field.save && date_of_birth_profile_field)
  end

  def localized_date_of_birth
    I18n.localize self.date_of_birth if self.date_of_birth
  end
  def localized_date_of_birth=(str)
    begin
      self.date_of_birth = str.to_date
    rescue
      self.date_of_birth = nil
    end
  end

  def age
    now = Time.now.utc.to_date
    dob = self.date_of_birth
    if dob
      now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    else
      nil
    end
  end

  def next_age
    age + 1 if age
  end

  def next_birthday
    if birthday_this_year.nil?
      nil
    elsif birthday_this_year > Time.zone.now
      birthday_this_year
    else
      birthday_this_year + 1.year
    end
  end

  def birthday_this_year
    begin
      date_of_birth.change(:year => Time.zone.now.year)
    rescue
      if date_of_birth.try(:month) == 2 && date_of_birth.try(:day) == 29
        date_of_birth.change(year: Time.zone.now.year, month: 3, day: 1)
      else
        nil
      end
    end
  end

end
