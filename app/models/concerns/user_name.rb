concern :UserName do

  # The name of the user, i.e. first_name and last_name.
  #
  def name
    "#{first_name} #{last_name}".strip
  end
  def name=(new_name)
    if new_name.present?
      self.last_name = new_name.strip.split(" ").last
      self.first_name = new_name.gsub(last_name, "").strip
    else
      self.last_name = nil
      self.first_name = nil
    end
  end


  def display_name
    display_name_fields.first.try(:value).to_s
  end

  def display_name=(new_display_name)
    field = display_name_fields.first_or_create
    field.value = new_display_name
    field.save
  end

  def display_name_fields
    profile_fields.where(type: "ProfileFields::General", label: "display_name")
  end


  # This method will make the first_name and the last_name capitalized.
  # For example:
  #
  #   @user = User.create( first_name: "john", last_name: "doe", ... )
  #   @user.capitalize_name  # => "John Doe"
  #   @user.save
  #   @user.name  # => "John Doe"
  #
  def capitalize_name
    self.first_name = capitalized_name_string( self.first_name )
    self.last_name = capitalized_name_string( self.last_name )
    self.name
  end

  def capitalized_name_string( name_string )
    return name_string if name_string.try(:include?, " ")
    return name_string.slice(0, 1).capitalize + name_string.slice(1..-1) if name_string.present?
  end
  private :capitalized_name_string

  def strip_first_and_last_name
    self.first_name = self.first_name.try(:strip)
    self.last_name = self.last_name.try(:strip)
  end

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  #
  # Notice: This method does *not* return the academic title of the user.
  #
  def title
    if display_name.present?
      display_name
    else
      name_and_affix
    end
  end

  def name_and_affix
    "#{name} #{name_affix}".gsub("  ", " ").strip
  end

  def name_affix
    "#{string_for_death_symbol}".strip
  end

  # For dead users, there is a cross symbol in the title.
  # (✝,✞,✟)
  #
  # More characters in this table:
  # http://www.utf8-chartable.de/unicode-utf8-table.pl?start=9984&names=2&utf8=-&unicodeinhtml=hex
  #
  def string_for_death_symbol
    "(✟)" if dead?
  end

  class_methods do

    # This method returns the first user matching the given title.
    #
    def find_by_title(title)
      ids = self.where("? LIKE CONCAT('%', first_name, ' ', last_name, '%')", title).pluck(:id)
      ids += ProfileField.where(type: "ProfileFields::General", label: "display_name").where("value LIKE ?", "%" + title + "%").collect { |profile_field| profile_field.profileable_id if profile_field.profileable_type == "User" } - [nil]
      self.where(id: ids.uniq).select do |user|
        user.title == title
      end.first
    end

    def find_by_name(name)
      self.find_all_by_name(name).limit(1).first
    end

    # This method finds all users having the given name attribute.
    # notice: case insensitive
    #
    def find_all_by_name(name) # TODO: Test this
      self.where("CONCAT(first_name, ' ', last_name) = ?", name)
    end

  end

end