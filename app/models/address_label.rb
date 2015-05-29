class AddressLabel
  attr_accessor :name
  attr_accessor :company
  attr_accessor :postal_address, :street, :postal_code, :state, :country_code, :country, :city
  attr_accessor :text_above_name, :text_below_name, :name_prefix, :name_suffix
  attr_accessor :personal_title
  
  def initialize(name, address_field, name_surrounding_field, personal_title = '', company = '')
    self.name = name
    self.company = company
    self.postal_address = address_field.try(:value)
    self.street = address_field.try(:geo_location).try(:street)
    self.postal_code = address_field.try(:postal_code)
    self.state = address_field.try(:geo_location).try(:state)
    self.country_code = address_field.try(:country_code)
    self.country = address_field.try(:geo_location).try(:country)
    self.city = address_field.try(:geo_location).try(:city)
    self.text_above_name = name_surrounding_field.try(:text_above_name).try(:strip)
    self.text_below_name = name_surrounding_field.try(:text_below_name).try(:strip)
    self.name_prefix = name_surrounding_field.try(:name_prefix).try(:strip)
    self.name_suffix = name_surrounding_field.try(:name_suffix).try(:strip)
    self.personal_title = personal_title
  end
  
  def to_s
    postal_address_with_name_surrounding
  end
  
  def postal_address_with_name_surrounding
    # text_before_the_name = name_prefix || ""
    # text_before_the_name += " #{personal_title}" if name_prefix != personal_title
    # ("#{text_above_name}\n" + 
    #   "#{text_before_the_name} #{name} #{name_suffix}\n" + 
    #   "#{text_below_name}\n" +
    #   (postal_address || "")
    # )
    (
      "#{text_above_name}\n" +
      "#{name_prefix} #{name} #{name_suffix}\n" +
      "#{text_below_name}\n" +
      "#{company}\n" + 
      (postal_address || "")
    )
    .gsub('  ', ' ')
    .gsub("\n\n\n", "\n")
    .gsub("\n\n", "\n")
    .gsub(" \n", "\n")
    .gsub("\n ", "\n")
    .strip
  end
  
  # This reduces the address label to a compact form:
  # No custom text above name, just title, name and address.
  #
  # Usage:
  # 
  #      address_label.to_s
  #      address_label.compact.to_s
  # 
  def compact
    herrn = to_s.include?("Herr") ? "Herrn " : ""
    title = personal_title.present? ? "#{personal_title} " : ""
    self.text_above_name = nil
    self.name_prefix = herrn + title
    self.name_suffix = nil
    self.text_below_name = nil
    convert_one_line_addresses    
    
    # remove country code from postal code
    #self.postal_address.gsub!(/^#{self.country_code}\s?-\s?/, "") 
    self.postal_address.gsub!(/^[A-Z][A-Z]?\s?-\s?/, "") if self.postal_address
    
    return self
  end
  
  # Convert last two lines to capital letters (versal) for
  # addresses abroad.
  #
  # Usage:     address_label.compact.versalize_abroad.to_s
  #
  def versalize_abroad
    if self.postal_address && country_code && country_code.downcase != I18n.locale.to_s.downcase
      address_lines = self.postal_address.split("\n")
      if address_lines.count > 1
        self.postal_address = (address_lines[0..-3] + address_lines[-2..-1].collect { |line| 
          line.upcase.gsub("ß", "SS").gsub("ä", "Ä").gsub("ö", "Ö").gsub("ü", "Ü")
        }).join("\n")
      end
    end
    return self
  end
  
  # We don't want one-line comma-separated addresses. Extract the last two
  # lines.
  #
  def convert_one_line_addresses
    if self.postal_address && self.postal_address.split("\n").count == 1
      address_lines = self.postal_address.split(", ")
      if address_lines.count > 1
        self.postal_address = address_lines[0..-3].join(", ") + "\n" + address_lines[-2..-1].join("\n")
      end
    end
    return self
  end
  
end