class AddressLabel
  attr_accessor :name
  attr_accessor :postal_address, :postal_code, :country_code, :country, :city
  attr_accessor :text_above_name, :text_below_name, :name_prefix, :name_suffix
  attr_accessor :personal_title
  
  def initialize(name, address_field, name_surrounding_field, personal_title = '')
    self.name = name
    self.postal_address = address_field.try(:value)
    self.postal_code = address_field.try(:postal_code)
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
      (postal_address || "")
    )
    .gsub('  ', ' ')
    .gsub("\n\n", "\n")
    .gsub(" \n", "\n")
    .gsub("\n ", "\n")
    .strip
  end
  
end