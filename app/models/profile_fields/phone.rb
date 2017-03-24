module ProfileFields

  # Phone Number Field
  #
  class Phone < ProfileField
    def self.model_name; ProfileField.model_name; end

    before_save :auto_format_value

    def self.format_phone_number( phone_number_str )
      return "" if phone_number_str.nil?
      value = phone_number_str

      # determine whether this is an international number
      format = :national
      format = :international if value.start_with?( "00" ) or value.start_with? ( "+" )

      # do only format international numbers, since for national numbers, the country
      # is unknown and each country formats its national area codes differently.
      if format == :international
        value = Phony.normalize( value ) # remove spaces etc.
        value = value[ 2..-1 ] if value.start_with?( "00" ) # because Phony can't handle leading 00
        value = value[ 1..-1 ] if value.start_with?( "+" ) # because Phony can't handle leading +
        value = Phony.formatted( value, :format => format, :spaces => ' ' )
      end

      return value
    end

    def vcard_property_type
      "TEL"
    end

    private
    def auto_format_value
      self.value = Phone.format_phone_number( self.value )
    end

  end

end