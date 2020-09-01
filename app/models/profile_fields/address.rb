module ProfileFields

  # Address Information
  #
  class Address < ProfileField
    def self.model_name; ProfileField.model_name; end

    def as_json(*args)
      super.merge({
        profileable_title: profileable_title,
        longitude: longitude,
        latitude: latitude,
        value: value,
        profileable_vcard_path: profileable_vcard_path
      })
    end

    def vcard_property_type
      "ADR"
    end

    def street_with_number
      geo_information(:street)
    end

    def country
      Biggs.country_names[country_code] if country_code
    end

    def country_if_not_default
      country if country_code != default_country_code
    end

    def country_code
      code = geo_information(:country_code) || default_country_code
      code.present? ? code.to_s.downcase : nil
    end

    def default_country_code
      self.class.default_country_code
    end

    def city
      geo_information(:city)
    end
    def town
      city
    end

    def postal_code
      geo_information(:postal_code)
    end

    def plz
      postal_code if country_code.try(:downcase) == 'de'
    end

    def province
      region
    end
    def state
      region
    end
    def region
      geo_information(:state)
    end
    def state_shortcut(str)
      GeoLocation.usa_state_shortcuts.each { |k, v| str.sub!(k, v) } if str.present?
      str
    end

    def self.default_country_code
      'DE'
    end

    def self.country_codes
      [default_country_code] + GeoLocation.country_codes.sort
    end

    def self.country_codes_hash
      Hash[*country_codes.zip(country_codes).flatten]
    end

    concerning :GoogleMapsIntegration do
      def as_json(options = nil)
        super(options).merge({
          position: {
            lng: longitude,
            lat: latitude
          },
          title: title,
          profileable_title: profileable.try(:title),
          profileable_type: profileable_type
        })
      end

      def title
        ([profileable.try(:title), label] - [nil]).join(", ")
      end
    end

    concerning :GeoCoding do
      def geo_location
        find_or_create_geo_location
      end

      def find_geo_location
        @geo_location ||= GeoLocation.find_by_address(value)
      end

      def find_or_create_geo_location
        @geo_location ||= GeoLocation.find_or_create_by address: value if self.value && self.value != "—"
      end

      def geo_information( key )
        return nil if self.value == "—"
        return geo_location.send(key).strip if self.value.present? && geo_location.send(key).kind_of?(String) && geo_location.send(key).strip.present?
        return geo_location.send(key) if self.value.present? && geo_location.send(key).present?
      end

      def geocoded?
        (find_geo_location && @geo_location.geocoded?).to_b
      end
      def geocode
        return @geo_location.geocode if @geo_location
        return @geo_location.geocode if find_geo_location
        return find_or_create_geo_location
      end

      def latitude
        geo_information :latitude
      end
      def longitude
        geo_information :longitude
      end
    end


    # Allow to mark one address as primary postal address.
    #
    concerning :PostalAddressFlag do
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
          RenewCacheJob.perform_later(self, time: Time.zone.now)
        end
      end
      def postal_address?
        self.postal_address
      end
      def clear_postal_address
        if self.profileable
          self.profileable.profile_fields.where(type: "ProfileFields::Address").each do |address_field|
            address_field.remove_flag :postal_address
          end
        end
      end
      def postal_or_first_address?
        postal_address? or (self.profileable && self.profileable.profile_fields.where(type: "ProfileFields::Address").order(:id).limit(1).pluck(:id).first == self.id)
      end
    end

    def self.fix_one_liner_addresses
      self.all.each do |address_field|
        if address_field.value && address_field.value.count("\n") == 0 && address_field.value.count(",").in?(1..3)
          address_field.value = address_field.value.gsub(", ", "\n")
          address_field.save
        end
      end
    end

    if use_caching?
      cache :longitude
      cache :latitude
      cache :profileable_title
      cache :profileable_vcard_path
      cache :profileable_alive_and_member?
    end

  end
end
