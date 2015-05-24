module ProfileFieldTypes

  # Address Information
  # 
  class Address < ProfileField
    def self.model_name; ProfileField.model_name; end

    attr_accessible :postal_address if defined? attr_accessible

    # Google Maps integration
    # see: http://rubydoc.info/gems/gmaps4rails/
    acts_as_gmappable
    
    def geo_location
      find_or_create_geo_location
    end

    def find_geo_location
      @geo_location ||= GeoLocation.find_by_address(value)
    end

    def find_or_create_geo_location
      @geo_location ||= GeoLocation.find_or_create_by address: value if self.value && self.value != "—"
    end

    def display_html
      ActionController::Base.helpers.simple_format self.value
    end

    # This is needed to display the map later.
    def gmaps4rails_address
      self.value
    end

    def gmaps
      true
    end

    def latitude ;      geo_information :latitude      end
    def longitude ;     geo_information :longitude     end
    def country ;       geo_information :country       end
    def country_code ;  geo_information :country_code  end
    def city ;          geo_information :city          end
    def postal_code ;   geo_information :postal_code   end
    def plz ;           geo_information :plz           end

    def geo_information( key )
      return nil if self.value == "—"
      geo_location.send( key ) if self.value
    end

    def geocoded?
      (find_geo_location && @geo_location.geocoded?).to_b
    end
    def geocode
      return @geo_location.geocode if @geo_location
      return @geo_location.geocode if find_geo_location
      return find_or_create_geo_location
    end

    # Allow to mark one address as primary postal address.
    # 
    def postal_address
      self.has_flag? :postal_address
    end 
    def postal_address=(new_postal_address)
      if new_postal_address != self.postal_address
        if new_postal_address
          self.clear_postal_address
          self.add_flag :postal_address
        else
          self.remove_flag :postal_address
        end
        self.delete_cache
      end
    end
    def postal_address?
      self.postal_address
    end
    def clear_postal_address
      self.profileable.profile_fields.where(type: "ProfileFieldTypes::Address").each do |address_field|
        address_field.remove_flag :postal_address
      end
    end
    def postal_or_first_address?
      postal_address? or (self.profileable.profile_fields.where(type: "ProfileFieldTypes::Address").order(:id).limit(1).pluck(:id).first == self.id)
    end
    
    
    def self.fix_one_liner_addresses
      self.all.each do |address_field|
        if address_field.value && address_field.value.count("\n") == 0 && address_field.value.count(",").in?(1..3)
          address_field.value = address_field.value.gsub(", ", "\n")
          address_field.save
        end
      end
    end

  end
  
end
