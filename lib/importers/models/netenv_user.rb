class NetenvUser

  # Rohdaten
  # =======================================================================

  def initialize( data_hash )
    @data_hash = data_hash
  end
  
  def data_hash_value( key )
    @data_hash[ key ] || @data_hash[ key.to_s ]
  end  
  
  
  # Name, Zugangsdaten
  # =======================================================================
    
  def first_name
    data_hash_value(:givenName).strip
  end
  
  def last_name
    data_hash_value(:sn).strip
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def alias
    data_hash_value :epdalias
  end
  
  def username
    self.alias
  end
  
  def w_nummer
    data_hash_value :uid
  end

  def email
    data_hash_value :mail
  end
  def do_not_import_primary_email
    @data_hash[:mail] = ""
  end
  
  
  # Informationen zum Datensatz
  # =======================================================================
  
  def created_at
    data_hash_value('createTimestamp').to_datetime
  end
  
  def updated_at
    data_hash_value('modifyTimestamp').to_datetime
  end
  
  def netenv_status
    data_hash_value(:epdstatus).try(:to_sym)
  end
  def deleted?
    netenv_status == :deleted
  end
  

  # Allgemeine Informationen zur Person
  # =======================================================================
  
  def date_of_birth
    begin
      data_hash_value(:epdbirthdate).to_date
    rescue # wrong date format
      return nil
    end
  end
  
  def personal_title
    (( [ data_hash_value('epdpersonaltitle') ] || [] ) + ( [ data_hash_value('epdpersonalothertitle') ] || [] )).join(" ")
  end
  
  def cognomen  # dt. Bierspitz
    data_hash_value :epdwingolfaktuelverbindvulgo
  end
  
  def klammerung
    data_hash_value :epdwingolfaktuelverbindklammerung
  end
  

  # Akademische Laufbahn
  # =======================================================================
  
  def academic_degrees
    (data_hash_value('epdeduacademictitle') ? data_hash_value('epdeduacademictitle') : "").split("|")
  end
  
  def academic_degree
    academic_degrees.join(" ")
  end
  
  def erstes_studiensemester
    data_hash_value :epdwingolfstat1studiensemester
  end
  
  def erstes_fachsemester
    data_hash_value :epdwingolfstat1fachsemester
  end
  
  def educational_area  # rer.nat.  etc.
    data_hash_value :epdeduarea
  end
  
  # Kontakt-Informationen
  # =======================================================================

  def home_email
    data_hash_value :epdprivateemailaddress
  end

  def work_email
    data_hash_value :epdprofemailaddress
  end
  
  def home_address
    "#{data_hash_value(:homePostalAddress)}\n" +
      "#{data_hash_value(:epdpersonalpostalcode)} #{data_hash_value(:epdpersonalcity)}\n" +
      "#{data_hash_value(:epdcountry)}"
  end
  def home_address_label
    ( data_hash_value('epdbuildingname') == "privat" ? nil : data_hash_value('epdbuildingname') ) || :home_address
  end

  def work_address
    "#{data_hash_value(:epdprofaddress)}\n" +
      "#{data_hash_value(:epdprofpostalcode)} #{data_hash_value(:epdprofcity)}\n" +
      "#{data_hash_value(:epdprofcountry)}"
  end
  def work_address_label
    data_hash_value('epdprofcompanyname') || ( aktiver? ? :study_address : :work_address )
  end
  
  def home_phone
    data_hash_value :homePhone
  end
  
  def work_phone
    data_hash_value :epdprofphone
  end
  
  def mobile
    data_hash_value :mobile
  end
  
  def home_fax
    data_hash_value :epdpersonalfax
  end
  
  def work_fax
    data_hash_value :epdproffax
  end
  
  def homepage
    data_hash_value :epdpersonallabeledurl
  end
  
  def work_homepage
    data_hash_value :epdproflabeledurl
  end
  
  
  # Beruf
  # =======================================================================
  
  def employment_status
    data_hash_value :epdprofworktype
  end
  
  def employment_title  # dt. Amtsbezeichnung
    data_hash_value :epdwingolfprofamtsbezeichnung
  end
  
  def professional_categories # dt. Berufsgruppen
    ( data_hash_value('epdprofposition') ? data_hash_value('epdprofposition') : "" ).split("|")
  end

  def occupational_areas # dt. Berufsfelder
    ( data_hash_value('epdprofbusinesscateogory') ? data_hash_value('epdprofbusinesscateogory') : "" ).split("|") +
      ( data_hash_value('epdproffieldofemployment') ? data_hash_value('epdproffieldofemployment') : "" ).split("|")
  end
  
  
  # Bank-Verbindung
  # =======================================================================

  def bank_account
    {
      :account_holder => data_hash_value('epdbankaccountowner'),
      :account_number => data_hash_value('epdbankaccountnr'), 
      :bank_code => data_hash_value('epdbankid'),
      :credit_institution => data_hash_value('epdbankinstitution'), 
      :iban => data_hash_value('epdbankiban'), 
      :bic => data_hash_value('epdbankswiftcode') 
    }
  end
  
  
  # Wingolfs-Status
  # =======================================================================
  
  def status
    data_hash_value(:epdorgstatusofperson)  # "Aktiver", "Philister", "Ehemaliger"
  end
  
  def aktiver?
    status == "Aktiver"
  end
  def philister?
    status == "Philister"
  end
  def ehemaliger?
    status == "Ehemaliger"
  end

  def verstorben?
    data_hash_value(:epdorgmembershipendreason) == "verstorben"
  end
  def deceased?
    verstorben?
  end
  
  
  # Aktivitätszahl
  # =======================================================================
  
  def ehemalige_netenv_aktivitätszahl
    data_hash_value(:epdwingolfformeractivities)
  end

  def netenv_aktivitätszahl
    data_hash_value(:epdwingolfactivity)
  end

  def aktivitätszahl
    if netenv_aktivitätszahl
      netenv_aktivitätszahl.gsub(" Eph ", "?Eph?").gsub(" Stft ", "?Stft?")
        .gsub(" Nstft ", "?Nstft?").gsub(" ", "").gsub(",", " ").gsub("?", " ")
    end
  end
  
  
  # Korporationen
  # =======================================================================
  
  # This method returns ALL corporations of this user, former AND current ones.
  def corporations
    (current_corporations + former_corporations).sort_by do |corporation|
      year_of_joining(corporation)
    end
  end
  
  def current_corporations
    corporations_by_netenv_aktivitätszahl( self.netenv_aktivitätszahl )
  end

  def former_corporations
    corporations_by_netenv_aktivitätszahl( self.ehemalige_netenv_aktivitätszahl )
  end

  def corporations_by_netenv_aktivitätszahl( str ) 
    # str == "E 12, Fr NStft 13"
    if str.present?

      raise 'TODO: HANDLE (E 12)-TYPE AKTIVITÄTSZAHLEN' if str.start_with? "("

      corporation_tokens = str.gsub(" Eph", "").gsub(" Stft", "").gsub(" Nstft", "")
        .gsub(/[0-9 ]+/, "").gsub(" ", "").split(",") 
      corporations = corporation_tokens.collect do |token|
        Corporation.find_by_token(token) || raise("Corporation #{token} not found.")
      end
    else
      []
    end
  end
  
  
  # Wingolfitische Vita
  # =======================================================================
  
  def aktivmeldungsdatum
    if (data_hash_value(:epdorgmembershipstartdate)) and (data_hash_value(:epdwingolfmutterverbindaktivmeldung)) 
      if (data_hash_value(:epdwingolfmutterverbindaktivmeldung) != data_hash_value(:epdorgmembershipstartdate))
        raise 'netenv data conflict: aktivmeldungsdatum and orgmembershipstart both given and unequal.'
      else
        return (data_hash_value(:epdorgmembershipstartdate) || data_hash_value(:epdwingolfmutterverbindaktivmeldung)).to_datetime
      end
    else
      # need to reconstruct the date using the aktivitätszahl attribute, since no
      # actual date is given.
      raise 'could not identify first corporation of user' if not corporations.first
      raise 'could not reconstruct year of joining' if not year_of_joining(corporations.first)
      return "#{year_of_joining(corporations.first)}-01-01".to_datetime
    end
  end
  
  def receptionsdatum
    data_hash_value(:epdwingolfmutterverbindrezeption).try(:to_datetime)
  end

  def burschungsdatum
    data_hash_value(:epdwingolfmutterverbindburschung).try(:to_datetime)
  end

  def philistrationsdatum
    data_hash_value(:epdwingolfaktuelverbindphilistration).try(:to_datetime)
  end
  
  def aktivität_by_corporation( corporation )
    parts = (netenv_aktivitätszahl.try(:split, ", ") || []) + (ehemalige_netenv_aktivitätszahl.try(:split, ", ") || [])
    parts.select { |part| part.start_with?(corporation.token + " ") }.first
  end
  def ehrenphilister?( corporation )
    aktivität_by_corporation(corporation).include? "Eph"
  end
  def stifter?( corporation )
    aktivität_by_corporation(corporation).include? "Stft"
  end
  def neustifter?( corporation )
    aktivität_by_corporation(corporation).include? "Nstft"
  end

  def bandaufnahme_als_aktiver?( corporation )
    return true if not philistrationsdatum
    raise 'Grenzfall!' if year_of_joining(corporation) == philistrationsdatum.year.to_s
    year_of_joining(corporation) < philistrationsdatum.year.to_s
  end

  def bandverleihung_als_philister?( corporation )
    return false if not philistrationsdatum
    raise 'Grenzfall!' if year_of_joining(corporation) == philistrationsdatum.year.to_s
    year_of_joining(corporation) > philistrationsdatum.year.to_s
  end
  
  
  # Austritte
  # =======================================================================
  
  def reason_for_exit( corporation = nil ) 
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    reason = description_of_exit(corporation).split(" - ").second
  end

  def date_of_exit( corporation = nil )
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    date = description_of_exit(corporation).split(" - ").first.to_datetime
  end

  def description_of_exit( corporation = nil )
    corporation ||= self.former_corporations.first
    # 07.06.2008 - Philistration - durch WV Hm|15.12.2010 - ausgetreten - durch WV Hm
    strs = self.descriptions
      .select{ |d| d.match(" #{corporation.token}$") }
      .select{ |d| d.include?("ausgetreten") || d.include?("gestrichen") }
    raise 'selection algorithm returnet non-uniqe result. please correct the algorithm for this case.' if strs.count > 1
    return strs.first
  end

  def descriptions 
    data_hash_value(:description).split("|")
  end

  def netenv_org_membership_end_date
    data_hash_value(:epdorgmembershipenddate).to_datetime
  end
    
  
  # Hilfsfunktionen zur Datums-Konvertierung
  # =======================================================================
  
  def year_of_joining( corporation )
    raise 'no corporation given.' if not corporation
    aktivität = aktivität_by_corporation(corporation)
    yy = aktivität.match( "[0-9][0-9]" )[0]
    yyyy = yy_to_yyyy(yy).to_s
  end

  def yy_to_yyyy( yy )
    # born 1950
    # 61 -> 1861?  1961?  2061?
    #              ----
    [ "18#{yy}", "19#{yy}", "20#{yy}" ].each do |year|
      return year if year > self.date_of_birth.year.to_s
    end
  end
  
  
  # Hilfsfunktionen zur Identifikation
  # =======================================================================
  
  def match?(attributes = {})
    return true if attributes == nil
    attributes.each do |key, value|
      return false if self.send(key) != value
    end
    return true
  end
  
  def dummy_user?
    netenv_aktivitätszahl.in?(["?????", "02", "03", "234", "VAW", "wingolf 00", "Wingolf 06", "wingolf 07"]) or
      (email.try(:include?, '@netenv') and email.try(:include?, 'iron.com'))  or
      name == "Tphil Tphil" or 
      name == "testadmin testadmin"
  end
    
  
end