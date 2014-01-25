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
    self.emails.last
  end
  def emails
    data_hash_value(:mail).try(:split, "|") || []
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
  def netenv_org_status
    data_hash_value(:epdorgstatusofperson).try(:to_sym)
  end
  def deleted?
    (netenv_status == :deleted) or netenv_org_status.blank?
  end
  def hidden?
    netenv_status == :silent
  end
  

  # Allgemeine Informationen zur Person
  # =======================================================================
  
  def former_name
    data_hash_value :epdwingolfoldsn
  end
  
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
  
  def employment_status  # dt. Beschäftigungsstatus
    data_hash_value :epdprofworktype
  end
  
  def employment_title  # dt. Amtsbezeichnung
    data_hash_value :epdwingolfprofamtsbezeichnung
  end
  
  def professional_categories # dt. Berufsgruppen
    ( data_hash_value('epdprofposition') ? data_hash_value('epdprofposition') : "" ).split("|")
  end

  def occupational_areas # dt. Berufsfelder, Tätigkeitsbereiche
    ( data_hash_value('epdprofbusinesscateogory') ? data_hash_value('epdprofbusinesscateogory') : "" ).split("|") +
      ( data_hash_value('epdproffieldofemployment') ? data_hash_value('epdproffieldofemployment') : "" ).split("|")
  end
  
  def native_languages
    (data_hash_value(:epdnativelanguage) || "").split("|")
  end
  
  def language_skills
    (data_hash_value(:epdforeignlanguages) || "").split("|")
  end
  
  def general_skills
    (data_hash_value(:epdwingolfgeneralcompetence) || "").split("|")
  end
  
  def professional_experiences  # mögliche Werte: Berufsberater, Entwickler, Projektleiter
    (data_hash_value(:epdwingolfprofcompetence) || "").split("|")
  end
  
  def activity_freetext  # Tätigkeit
    data_hash_value :epdprofcompbusinessdescr
  end
  
  def offerings
    study_offerings + professional_offerings
  end
  
  def professional_offerings
    (data_hash_value(:epdwingolfangeboteberufsberavailible) || "").split("|")
  end
  
  def study_offerings
    (data_hash_value(:epdwingolfangebotestudienfreetime) || "").split("|")
  end

  def offering_talk_about  # Biete Vortrag zum Thema
    data_hash_value :epdwingolfangebotevortragtitle
  end
  
  def offering_training   # Biete Praktika
    data_hash_value :epdwingolfangebotepraktikafreetime
  end
  
  def offering_freetext
    data_hash_value :epdwingolfangeboteberufsberfreetime
  end

  def requests   # Gesuche
    (data_hash_value(:epdwingolfangebotesearch) || "").split("|")
  end
  
  def request_freetext
    data_hash_value :epdwingolfangebotesearchdescription
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
  
  
  # Kommunikation
  # =======================================================================
  
  def wbl_abo?
    data_hash_value(:epdwingolfmagazine) == "Y"
  end
  
  def text_above_name  # Bevorzugte Anrede
    data_hash_value :epdwingolfpreferredanrede
  end
  
  def name_prefix
    personal_title
  end
  
  def name_suffix
    data_hash_value :epdwingolfnamesuffix2
  end
  
  def text_below_name
    data_hash_value :epdnamesuffix
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
  
  def netenv_aktivitätszahl
    fix_netenv_aktivitätszahl_format data_hash_value :epdwingolfactivity
  end

  def ehemalige_netenv_aktivitätszahl
    fix_netenv_aktivitätszahl_format data_hash_value :epdwingolfformeractivities
  end

  def aktivitätszahl
    if netenv_aktivitätszahl
      netenv_aktivitätszahl.gsub(" Eph ", "?Eph?").gsub(" Stft ", "?Stft?")
        .gsub(" Nstft ", "?Nstft?").gsub(" ", "").gsub(",", " ").gsub("?", " ")
    end
  end
  
  # Nach Information Büscher handelt es sich bei der Klammer-Schreibweise lediglich um 
  # eine ältere Notation. Die Schreibweisen "(E 32)" und "E 32" bedeuten die gleiche
  # Aktivität. Daher werden hier die Klammern schlicht entfernt, um eine einheitliche
  # Verarbeitung zu ermöglichen.
  #
  def remove_brackets(str)
    str.gsub("(", "").gsub(")", "") if str
  end
  private :remove_brackets
  
  # Diese Methode korrigiert einige Inkonsistenzen in der Form der 
  # netenv_aktivitätszahl:
  # 
  #   * Klammern ohne Bedeutung entfernen
  #   * Leerzeichen am Anfang und am Ende entfernen
  #   * fehlende Leerzeichen nach Komma ergänzen
  #   * fehlende Leerzeichen zwischen Verbindungskürzel und Jahreszahl ergänzen
  #   * doppelte Leerzeichen entfernen
  #   * Ersetzung der schweizer Kürzel
  #   * Sonderfälle berücksichtigen
  # 
  def fix_netenv_aktivitätszahl_format(str)
    if str
      str = remove_brackets(str)
      str = str.gsub(",", ", ").gsub("   ", " ").gsub("  ", " ").strip
      str = str.gsub(/([A-Za-z])([0-9])/, "\\1 \\2")
      
      # Die schweizer Verbindungen sind nicht immer auf gleiche Art in die Aktivitätszahlen
      # eingetragen. Daher muss hier eine Ersetzung stattfinden, um sie zu vereinheitlichen.
      #
      #   Schwizerhüsli Basilensis      "Basel", "Ba", "S!"
      #   Zähringia Bernensis           "Bern",        "Z!"
      #   Carolingia Turicensis         "Ca",    "Z"   "C!"
      #   Valdésia Lausannensis         "La",          "V!"
      #
      str = str.gsub("Basel ", "S! ").gsub("Ba ", "S! ")
      str = str.gsub("Bern ", "Z! ")
      str = str.gsub("Ca ", "C! ").gsub("Z ", "C! ")
      str = str.gsub("La ", "V! ")
      
      # Es gibt ein paar Fälle von Philistern mit irregulärer Aktivitätszahl.
      # 
      str = str.gsub("Hg 59, Be 58", "Be 58, Hg 59")  # W53802. Telefonisch bestätigt. War falsch eingetragen.
      str = str.gsub("J 00, L 02", "Je 00, L 02")  # W54315. Jena falsch abgekürzt.
      
    end
  end
  private :fix_netenv_aktivitätszahl_format
  
  
  # Korporationen
  # =======================================================================
  
  # This method returns ALL corporations of this user, former AND current ones.
  def corporations
    (current_corporations + former_corporations).sort_by do |corporation|
      year_of_joining(corporation)
    end
  end
  
  def primary_corporation
    self.corporations.first
  end
  
  def secondary_corporations
    current_corporations - [ primary_corporation ]
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
    date = aktivmeldungsdatum_in_mutterverbindung || aktivmeldungsdatum_im_wingolfsbund || aktivmeldungsdatum_aus_aktivitaetszahl
    if date.year != aktivmeldungsdatum_aus_aktivitaetszahl.year
      # Für Fälle, in denen ein Aktivmeldungsdatum angegeben ist, das der Aktivitätszahl widerspricht,
      # wird die Aktivätszahl als korrekt angenommen, da diese eher auffallen dürfte.
      # Beispiel: W51032
      date = aktivmeldungsdatum_aus_aktivitaetszahl 
    end
    return date
  end
  
  def aktivmeldungsdatum_in_mutterverbindung
    data_hash_value(:epdwingolfmutterverbindaktivmeldung).try(:to_datetime)
  end
  
  def aktivmeldungsdatum_im_wingolfsbund
    data_hash_value(:epdorgmembershipstartdate).try(:to_datetime)
  end
  
  def aktivmeldungsdatum_aus_aktivitaetszahl
    raise 'could not identify first corporation of user' if not corporations.first
    raise 'could not reconstruct year of joining' if not year_of_joining(corporations.first)
    return "#{year_of_joining(corporations.first)}-01-01".to_datetime
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
    
    # Wenn ein Philistrationsdatum bekannt ist, wird dieses zum Vergleich verwendet.
    if philistrationsdatum
      # Im Grenzfall, wo Philistrationsjahr und Jahr der Bandaufnahme/Bandverleihung 
      # gleich sind, wird angenommen, das das Band als Philister verliehen wurde.
      #
      year_of_joining(corporation) < philistrationsdatum.year.to_s
      
    # Wenn kein Philistrationsdatum bekannt ist, wird stattdessen willkürlich angenommen,
    # dass eine Bandaufnahme innerhalb der sechs Jahre nach Aktivmeldung als Aktiver erfolgt.
    else
      year_of_joining(corporation).to_datetime < aktivmeldungsdatum + 6.years
    end
  end

  def bandverleihung_als_philister?( corporation )
    not bandaufnahme_als_aktiver?(corporation)
  end
  
  
  # Austritte
  # =======================================================================
  
  def reason_for_exit( corporation = nil ) 
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    reason = description_of_exit(corporation).split(" - ").second if description_of_exit(corporation)
  end

  def date_of_exit( corporation = nil )
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    date = description_of_exit(corporation).split(" - ").first.to_datetime if description_of_exit(corporation)
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
    if data_hash_value(:description).present?
      data_hash_value(:description)
        .gsub(";", "|")
        .gsub("\n", "|")
        .split("|")
        .select { |desc| desc.present? }
    else
      []
    end
  end

  def netenv_org_membership_end_date
    data_hash_value(:epdorgmembershipenddate).try(:to_datetime)
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
      # Wenn kein Geburtsdatum angegeben ist, nehmen wir eine zeitnahe Aktivmeldung an.
      return year if year > (self.date_of_birth || 99.years.ago).year.to_s
    end
  end
  
  def assumed_date_of_joining( corporation )
    year_of_joining(corporation).to_datetime
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