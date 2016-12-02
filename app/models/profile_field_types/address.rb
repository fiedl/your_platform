module ProfileFieldTypes

  # Address Information
  #
  class Address < ProfileField
    def self.model_name; ProfileField.model_name; end

    # def display_html
    #   ActionController::Base.helpers.simple_format self.value
    # end

    def vcard_property_type
      "ADR"
    end

    concerning :SubFields do
      included do
        has_child_profile_fields :first_address_line, :second_address_line, :postal_code, :city, :region, :country_code

        def street_with_number
          self.get_field(:first_address_line) || geo_information(:street)
        end

        def country
          Biggs.country_names[country_code] if country_code
        end

        def country_if_not_default
          country if country_code != default_country_code
        end

        def country_code
          code = self.get_field(:country_code) || geo_information(:country_code) || default_country_code
          code.present? ? code.to_s.downcase : nil
        end

        def default_country_code
          'de'
        end

        def city
          self.get_field(:city) || geo_information(:city)
        end

        def postal_code
          self.get_field(:postal_code) || geo_information(:postal_code)
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
          self.get_field(:region) || geo_information(:state)
        end

        def composed_address
          first_and_second_address_line = (get_field(:first_address_line).to_s + "\n" + get_field(:second_address_line).to_s).strip
          Biggs::Formatter.new(blank_country_on: default_country_code).format(
            get_field(:country_code),
            street: first_and_second_address_line,
            city: get_field(:city),
            zip: get_field(:postal_code),
            state: get_field(:region)
          ).strip
        end

        def original_value
          read_attribute :value
        end

        def value
          if first_address_line.present?
            composed_address
          else
            original_value
          end
        end

        # First, we had all address fields store as free-text value.
        # This method migrates this format to the new one where street, city etc.
        # are stored as separate child profile fields.
        #
        def convert_to_format_with_separate_fields
          # p "converting profile field #{id} of #{profileable.try(:class).try(:name)} #{profileable.try(:id)} ..."

          old_value = self.value

          if self.geo_information(:street).present?
            self.first_address_line = self.geo_information(:street)
            self.city = self.geo_information(:city)
            self.postal_code = self.geo_information(:postal_code)
            self.country_code = self.geo_information(:country_code)
          else
            # If we haven't processed this field already.
            #
            unless self.get_field(:first_address_line).present?
              # If we can't extract the street name, copy the whole address into
              # the second address line field. Otherwise, we'd lose this information
              # in the ui.
              #
              self.second_address_line = self.read_attribute(:value)
              self.add_flag :needs_review
            end
          end

          # For foreign addresses, better include the state/region field, since
          # we do not know if this field is needed there.
          #
          if self.geo_information(:country_code).present? && self.geo_information(:country_code).try(:downcase) != default_country_code.try(:downcase)
            self.region = self.geo_information(:state)
          end

          if old_value && self.value && [old_value, self.value].collect { |v|
              v.gsub("traße", "tr.").gsub("\n", "").gsub(",", "").gsub(" ", "")
            }.uniq.count == 2
            # The old and the new value differ. This could simply mean that
            # "Frankreich" has been replaced by "France". But it could also mean
            # that the address is not readable anymore. In any case, it should
            # be checked manually.
            #
            self.add_flag :needs_review
          end

          self.save

          return self
        end
      end
    end

    # Google Maps integration
    # see: http://rubydoc.info/gems/gmaps4rails/
    #
    acts_as_gmappable
    concerning :GoogleMapsIntegration do
      def gmaps4rails_address
        self.value
      end

      def gmaps
        true
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
    attr_accessible :postal_address if defined? attr_accessible
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
          self.renew_cache
        end
      end
      def postal_address?
        self.postal_address
      end
      def clear_postal_address
        if self.profileable
          self.profileable.profile_fields.where(type: "ProfileFieldTypes::Address").each do |address_field|
            address_field.remove_flag :postal_address
          end
        end
      end
      def postal_or_first_address?
        postal_address? or (self.profileable && self.profileable.profile_fields.where(type: "ProfileFieldTypes::Address").order(:id).limit(1).pluck(:id).first == self.id)
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

  end
end
