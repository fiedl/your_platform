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
      name_and_affix
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

end