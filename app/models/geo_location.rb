class GeoLocation < ActiveRecord::Base
  attr_accessible :address if defined? attr_accessible


  # When to perform geocoding queries (to google)
  # ==========================================================================================

  after_validation :geocode, :if => [ 'address_changed?', 'latitude.nil?' ]
  after_find :geocode_and_save, :if => 'latitude.nil?'


  # What to do when performing a geocoding query (to google)
  # ==========================================================================================

  geocoded_by :address, language: I18n.locale do |geo_location, geo_query_results|
    result = geo_query_results.first
    if result
      # Definition of `result` with available methods can be found here:
      # https://github.com/alexreisner/geocoder/blob/master/lib/geocoder/results/google.rb
      geo_location.latitude = result.latitude
      geo_location.longitude = result.longitude
      geo_location.city = result.city
      geo_location.country = result.country
      geo_location.country_code = result.country_code
      geo_location.postal_code = result.postal_code
      geo_location.street = [result.route, result.street_number].join(" ")
      geo_location.state = result.state
      
      # There is no way to determine whether the street format is
      # `{{street name}} {{street number}}` or `{{street number}} {{street name}}`.
      # Therefore take the format from the original input.
      #
      if result.address.try(:include?, [result.street_number, result.route].join(" "))
        geo_location.street = [result.street_number, result.route].join(" ")
      else
        geo_location.street = [result.route, result.street_number].join(" ")
      end
    end
    self
  end
  
  # This method performs the geociding query and stores the query datetime. 
  #
  def geocode
    self.queried_at = DateTime.now
    begin
      super
    rescue ArgumentError => e
      raise e unless Rails.env.test?
    end
  end

  # Perform geocode query and save the record.
  # This is needed after finding a record where no geocode query has been done, yet.
  #
  def geocode_and_save
    geocode
    save
  end

  # This method returns `true` if the geocoding query has been performed, already.  
  #
  # After a query, the attributes may still be empty, since this might be an
  # invalid address. Therefore, it's good to know, whether the query has been
  # done already.
  #
  def geocoded?
    (queried_at.present? || country_code.present?)
  end


  # Finder Methods
  # ==========================================================================================

  # Find a geo_location object by address string. 
  # If the address already exists in the database, return the object from
  # the database. Otherwise, create a new database entry for the address
  # and perform a geocoding query.
  #
  # This method is already defined be ActiveRecord.
  #
  # def self.find_or_create_by_address( address_string )
  # end


  # Country Specific Methods
  # ==========================================================================================

  # This method returns true if the location is in Europe.
  #
  def in_europe?
    country_code.in? GeoLocation.european_country_codes
  end
  
  def self.european_country_codes
    %w(AD AL AT BA BE BG BY CH CY CZ DE DK EE ES FI FO FR GG GI GR GB HR HU IE IM IS IT JE LI LT LU LV MC MD\
     MK MT NL NO PL PT RO RU SE SI SJ SK SM TR UA UK VA YU)
  end

  # The following method is a country-specific accessor to the the German
  # Postleitzahl (PLZ). If returns the German postal code if the
  # address is in Germany. Otherwise, it returns nil.
  #
  # There are cases when the maps api can't isolate the postal code. 
  # In this case, the `postal_code` returns `nil`.
  # Try to get it from the regex then.
  #
  def plz
    if country_code == "DE"
      postal_code || address.match(/(\d{5})/).try(:[], 1)
    end
  end
  
  # This returns the country code by ISO 3166-1-Alpha-3.
  #
  # Example: 
  #
  #     User.first.address_fields.first.geo_location.country_code_with_3_letters
  #     #  => "DEU"
  #
  def country_code_with_3_letters
    GeoLocation.country_codes_3_letters_from_2_letters[self.country_code]
  end
  
  # This is a hash mapping of ISO 3166-1-Alpha-2 to ISO 3166-1-Alpha-3.
  # See this issue: https://github.com/fiedl/wingolfsplattform/issues/67.
  #
  def self.country_codes_3_letters_from_2_letters
    {
      "AD" => "AND",
      "AE" => "ARE",
      "AF" => "AFG",
      "AG" => "ATG",
      "AI" => "AIA",
      "AL" => "ALB",
      "AM" => "ARM",
      "AO" => "AGO",
      "AQ" => "ATA",
      "AR" => "ARG",
      "AS" => "ASM",
      "AT" => "AUT",
      "AU" => "AUS",
      "AW" => "ABW",
      "AX" => "ALA",
      "AZ" => "AZE",
      "BA" => "BIH",
      "BB" => "BRB",
      "BD" => "BGD",
      "BE" => "BEL",
      "BF" => "BFA",
      "BG" => "BGR",
      "BH" => "BHR",
      "BI" => "BDI",
      "BJ" => "BEN",
      "BL" => "BLM",
      "BM" => "BMU",
      "BN" => "BRN",
      "BO" => "BOL",
      "BQ" => "BES",
      "BR" => "BRA",
      "BS" => "BHS",
      "BT" => "BTN",
      "BV" => "BVT",
      "BW" => "BWA",
      "BY" => "BLR",
      "BZ" => "BLZ",
      "CA" => "CAN",
      "CC" => "CCK",
      "CD" => "COD",
      "CF" => "CAF",
      "CG" => "COG",
      "CH" => "CHE",
      "CI" => "CIV",
      "CK" => "COK",
      "CL" => "CHL",
      "CM" => "CMR",
      "CN" => "CHN",
      "CO" => "COL",
      "CR" => "CRI",
      "CU" => "CUB",
      "CV" => "CPV",
      "CW" => "CUW",
      "CX" => "CXR",
      "CY" => "CYP",
      "CZ" => "CZE",
      "DE" => "DEU",
      "DJ" => "DJI",
      "DK" => "DNK",
      "DM" => "DMA",
      "DO" => "DOM",
      "DZ" => "DZA",
      "EC" => "ECU",
      "EE" => "EST",
      "EG" => "EGY",
      "EH" => "ESH",
      "ER" => "ERI",
      "ES" => "ESP",
      "ET" => "ETH",
      "FI" => "FIN",
      "FJ" => "FJI",
      "FK" => "FLK",
      "FM" => "FSM",
      "FO" => "FRO",
      "FR" => "FRA",
      "GA" => "GAB",
      "GB" => "GBR",
      "GD" => "GRD",
      "GE" => "GEO",
      "GF" => "GUF",
      "GG" => "GGY",
      "GH" => "GHA",
      "GI" => "GIB",
      "GL" => "GRL",
      "GM" => "GMB",
      "GN" => "GIN",
      "GP" => "GLP",
      "GQ" => "GNQ",
      "GR" => "GRC",
      "GS" => "SGS",
      "GT" => "GTM",
      "GU" => "GUM",
      "GW" => "GNB",
      "GY" => "GUY",
      "HK" => "HKG",
      "HM" => "HMD",
      "HN" => "HND",
      "HR" => "HRV",
      "HT" => "HTI",
      "HU" => "HUN",
      "ID" => "IDN",
      "IE" => "IRL",
      "IL" => "ISR",
      "IM" => "IMN",
      "IN" => "IND",
      "IO" => "IOT",
      "IQ" => "IRQ",
      "IR" => "IRN",
      "IS" => "ISL",
      "IT" => "ITA",
      "JE" => "JEY",
      "JM" => "JAM",
      "JO" => "JOR",
      "JP" => "JPN",
      "KE" => "KEN",
      "KG" => "KGZ",
      "KH" => "KHM",
      "KI" => "KIR",
      "KM" => "COM",
      "KN" => "KNA",
      "KP" => "PRK",
      "KR" => "KOR",
      "XK" => "XKX",
      "KW" => "KWT",
      "KY" => "CYM",
      "KZ" => "KAZ",
      "LA" => "LAO",
      "LB" => "LBN",
      "LC" => "LCA",
      "LI" => "LIE",
      "LK" => "LKA",
      "LR" => "LBR",
      "LS" => "LSO",
      "LT" => "LTU",
      "LU" => "LUX",
      "LV" => "LVA",
      "LY" => "LBY",
      "MA" => "MAR",
      "MC" => "MCO",
      "MD" => "MDA",
      "ME" => "MNE",
      "MF" => "MAF",
      "MG" => "MDG",
      "MH" => "MHL",
      "MK" => "MKD",
      "ML" => "MLI",
      "MM" => "MMR",
      "MN" => "MNG",
      "MO" => "MAC",
      "MP" => "MNP",
      "MQ" => "MTQ",
      "MR" => "MRT",
      "MS" => "MSR",
      "MT" => "MLT",
      "MU" => "MUS",
      "MV" => "MDV",
      "MW" => "MWI",
      "MX" => "MEX",
      "MY" => "MYS",
      "MZ" => "MOZ",
      "NA" => "NAM",
      "NC" => "NCL",
      "NE" => "NER",
      "NF" => "NFK",
      "NG" => "NGA",
      "NI" => "NIC",
      "NL" => "NLD",
      "NO" => "NOR",
      "NP" => "NPL",
      "NR" => "NRU",
      "NU" => "NIU",
      "NZ" => "NZL",
      "OM" => "OMN",
      "PA" => "PAN",
      "PE" => "PER",
      "PF" => "PYF",
      "PG" => "PNG",
      "PH" => "PHL",
      "PK" => "PAK",
      "PL" => "POL",
      "PM" => "SPM",
      "PN" => "PCN",
      "PR" => "PRI",
      "PS" => "PSE",
      "PT" => "PRT",
      "PW" => "PLW",
      "PY" => "PRY",
      "QA" => "QAT",
      "RE" => "REU",
      "RO" => "ROU",
      "RS" => "SRB",
      "RU" => "RUS",
      "RW" => "RWA",
      "SA" => "SAU",
      "SB" => "SLB",
      "SC" => "SYC",
      "SD" => "SDN",
      "SS" => "SSD",
      "SE" => "SWE",
      "SG" => "SGP",
      "SH" => "SHN",
      "SI" => "SVN",
      "SJ" => "SJM",
      "SK" => "SVK",
      "SL" => "SLE",
      "SM" => "SMR",
      "SN" => "SEN",
      "SO" => "SOM",
      "SR" => "SUR",
      "ST" => "STP",
      "SV" => "SLV",
      "SX" => "SXM",
      "SY" => "SYR",
      "SZ" => "SWZ",
      "TC" => "TCA",
      "TD" => "TCD",
      "TF" => "ATF",
      "TG" => "TGO",
      "TH" => "THA",
      "TJ" => "TJK",
      "TK" => "TKL",
      "TL" => "TLS",
      "TM" => "TKM",
      "TN" => "TUN",
      "TO" => "TON",
      "TR" => "TUR",
      "TT" => "TTO",
      "TV" => "TUV",
      "TW" => "TWN",
      "TZ" => "TZA",
      "UA" => "UKR",
      "UG" => "UGA",
      "UM" => "UMI",
      "US" => "USA",
      "UY" => "URY",
      "UZ" => "UZB",
      "VA" => "VAT",
      "VC" => "VCT",
      "VE" => "VEN",
      "VG" => "VGB",
      "VI" => "VIR",
      "VN" => "VNM",
      "VU" => "VUT",
      "WF" => "WLF",
      "WS" => "WSM",
      "YE" => "YEM",
      "YT" => "MYT",
      "ZA" => "ZAF",
      "ZM" => "ZMB",
      "ZW" => "ZWE",
      "CS" => "SCG",
      "AN" => "ANT"
    }
  end
  
  def self.country_codes
    self.country_codes_3_letters_from_2_letters.keys
  end

end
