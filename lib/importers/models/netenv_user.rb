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
    data_hash_value(:givenName).try(:strip)
  end
  
  def last_name
    data_hash_value(:sn).try(:strip)
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
    self.emails.last || home_email || work_email
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
    data_hash_value('createTimestamp').try(:to_datetime)
  end
  
  def updated_at
    data_hash_value('modifyTimestamp').try(:to_datetime)
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
  
  def type_of_study
    # "Bachelor/Master", "Diplom", "Kirchliche Prüfung", "Magister", "Promotion", "Staatsprüfung"
    type = data_hash_value :epdwingolfedustudystatus
    type = "Bachelor-Master-Studium"         if type == "Bachelor/Master"
    type = "Diplom-Studium"                  if type == "Diplom"
    type = "Studium mit kirchlicher Prüfung" if type == "Kirchliche Prüfung"
    type = "Magister-Studium"                if type == "Magister"
    type = "Promotion"                       if type == "Promotion"
    type = "Studium mit Staatsprüfung"       if type == "Staatsprüfung"
    return type
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
  
  def work_mobile
    data_hash_value :epdprofmobilephone
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
  
  def preferred_address
    flag = data_hash_value(:epdpreferredcontactaddress)  # "", "prof_address", "address_personal"
    (flag == 'prof_address') ? :work_address : :home_address
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
    (data_hash_value(:epdwingolfmagazine) == "Y") and not ehemaliger?
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
    status == "Ehemaliger" || netenv_org_membership_end_date.present?
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

    # Es gibt Fälle, z.B. W65397, wo fälschlicherweise als ehemalige Aktivitätszahl
    # und als aktuelle Aktivitätszahl das gleiche eingegeben ist. Im Einzelfall ist 
    # zu prüfen, was die plausiblere Angabe ist.
    #
    return nil if w_nummer == "W51241"  # Austritt vermerkt. Wird aktuell als ausgetreten geführt.

    fix_netenv_aktivitätszahl_format data_hash_value :epdwingolfactivity
  end

  def ehemalige_netenv_aktivitätszahl
    
    # Es gibt Fälle, z.B. W65397, wo fälschlicherweise als ehemalige Aktivitätszahl
    # und als aktuelle Aktivitätszahl das gleiche eingegeben ist. Im Einzelfall ist 
    # zu prüfen, was die plausiblere Angabe ist.
    #
    return nil if w_nummer == "W65397"  # Kein Austritt vermerkt. Wird aktuell als Mitglied geführt.
    
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
      str = str.gsub(";", ",")
      str = str.gsub(/^,/, "").gsub(/,$/, "")
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
      str = str.gsub("HV ", "Hv ")  # W64248. Hannover falsch abgekürzt.
      str = str.gsub("Cacl ", "CaCl ")  # W64409. Clausthaler Wingolf Catena falsch abgekürzt.
      str = str.gsub("M 05", "M 04") if w_nummer == "W64573"  # W64573. Aktivmeldungsdatum von 2004. Zwischenzeitlich ausgetreten.
      str = str.gsub("Be 06", "Be 95") if w_nummer == "W64682"  # W64682. Aktivmeldung 1995, konsistentes Geburtsdatum. Aktivitätszahl vermutlich falsch eingetragen. BV-Wechsel war 2006.
      str = str.gsub("Hm 09", "Hm 08") if w_nummer == "W65085"  # W65085. Aktivmeldung 2008.
      str = str.gsub("HB ", "Hb ")  # W51944. Hamburg falsch abgekürzt.
      str = str.gsub("Ef 08, Je 06", "Ef 08") if w_nummer == "W64703"  # 64703. Ist in Jena ausgetreten.
      
      str = str.gsub("Dr 93, Dr Nstft 97", "Dr Nstft 93")  # W54409. TODO: Diese Aktivitätszahl muss noch gedeutet und das Programm entsprechend angepasst werden. Zunächst Telefonat, um die korrekte Aktivitätszahl festzustellen.
      

      
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
    current_corporations + former_corporations - [ primary_corporation ]
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
  
  def angegebenes_aktivmeldungsdatum
    aktivmeldungsdatum_im_wingolfsbund || aktivmeldungsdatum_in_mutterverbindung
  end
  
  def angegebenes_aktivmeldungsdatum_passt_nicht_zur_aktivitätszahl?
    angegebenes_aktivmeldungsdatum.present? and ( angegebenes_aktivmeldungsdatum.year != aktivmeldungsdatum_aus_aktivitaetszahl.year )
  end
  
  def angegebenes_aktivmeldungsdatum_geschätzt?
    (data_hash_value(:epdwingolfmutterverbindaktivmeldung).present? and data_hash_value(:epdwingolfmutterverbindaktivmeldung).datetime_is_estimate?) or
      (data_hash_value(:epdorgmembershipstartdate).present? and data_hash_value(:epdorgmembershipstartdate).datetime_is_estimate?)
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
  
  def aktivmeldungsdatum_geschätzt?
    angegebenes_aktivmeldungsdatum.blank? or 
      angegebenes_aktivmeldungsdatum_geschätzt? or
      angegebenes_aktivmeldungsdatum_passt_nicht_zur_aktivitätszahl?
  end
  
  def receptionsdatum
    date = data_hash_value(:epdwingolfmutterverbindrezeption).try(:to_datetime)
    return nil unless date
    
    # Es gibt Fälle, z.B. W64562, wo das Receptionsdatum eher dem Geburtsdatum entspricht
    # und nicht nach dem Aktivmeldungsdatum liegt. In diesem Fall sollte das Receptions-
    # datum ignoriert werden, da es sonst die Aktivitätszahl verfälscht.
    #
    return nil if date_of_birth.try(:to_datetime) == date.to_datetime
    return date
  end
  
  def receptionsdatum_geschätzt?
    data_hash_value(:epdwingolfmutterverbindrezeption).try(:datetime_is_estimate?)
  end
  
  def reception_als_konkneipant?
    (last_known_status_group_in( primary_corporation ) == "Konkneipant") or
    (letzter_angegebener_status_als_aktiver == "Konkneipant")
  end

  def burschungsdatum
    data_hash_value(:epdwingolfmutterverbindburschung).try(:to_datetime)
  end
  
  def burschungsdatum_geschätzt?
    data_hash_value(:epdwingolfmutterverbindburschung).try(:datetime_is_estimate?)
  end

  def philistrationsdatum
    angegebenes_philistrationsdatum || geschätztes_philistrationsdatum
  end
  
  def angegebenes_philistrationsdatum
    data_hash_value(:epdwingolfaktuelverbindphilistration).try(:to_datetime) || philistrationsdatum_from_description
  end
  
  def angegebenes_philistrationsdatum_geschätzt?
    data_hash_value(:epdwingolfaktuelverbindphilistration).try(:datetime_is_estimate?)
  end
  
  def geschätztes_philistrationsdatum
    aktivmeldungsdatum if philister?
  end
  
  def philistrationsdatum_geschätzt?
    angegebenes_philistrationsdatum.blank? || angegebenes_philistrationsdatum_geschätzt?
  end
  
  def philistrationsdatum_from_description
    descriptions.each do |str|
      # "Philistration am 02.06.2005"
      str = str.match(/^Philistration am (.*)$/)
      return str[1].to_datetime if str
    end
    return nil
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
  
  def letzter_angegebener_status_als_aktiver
    data_hash_value :epdwingolfaktuelverbindstatus
  end



  # Bandaufnahmen
  # =======================================================================

  def bandaufnahme_als_aktiver?( corporation )
    
    # Wenn ein Philistrationsdatum bekannt ist, wird dieses zum Vergleich verwendet.
    if angegebenes_philistrationsdatum
      
      # Im Grenzfall, wo Philistrationsjahr und Jahr der Bandaufnahme/Bandverleihung 
      # gleich sind, wird angenommen, das das Band als Philister verliehen wurde.
      #
      year_of_joining(corporation) < angegebenes_philistrationsdatum.year.to_s
      
    # Wenn kein Philistrationsdatum bekannt ist, wird stattdessen willkürlich angenommen,
    # dass eine Bandaufnahme innerhalb der sechs Jahre nach Aktivmeldung als Aktiver erfolgt.
    else
      year_of_joining(corporation).to_datetime < aktivmeldungsdatum + 6.years
    end
  end

  def bandverleihung_als_philister?( corporation )
    not bandaufnahme_als_aktiver?(corporation)
  end
  
  def beitrittsdatum_geschätzt?( corporation )
    if corporation == primary_corporation
      aktivmeldungsdatum_geschätzt?
    else
      angegebenes_bandaufnahmedatum.blank? or (angegebenes_bandaufnahmedatum.year != assumed_date_of_joining(corporation).year)
    end
  end
  
  def beitrittsdatum( corporation )
    if corporation == primary_corporation
      aktivmeldungsdatum
    else
      # Es gibt nur ein weiteres vermerktes Bandaufnahmedatum. Wenn es insgesamt drei Korporationen 
      # gibt, ist die Information verloren. Anhand des Jahres wird geprüft, ob es sich hier um das 
      # richtige Datum handelt.
      #
      if angegebenes_bandaufnahmedatum
        if angegebenes_bandaufnahmedatum.year == assumed_date_of_joining(corporation).year
          return angegebenes_bandaufnahmedatum
        else
          return assumed_date_of_joining( corporation )
        end
      end
    end
  end
  
  def angegebenes_bandaufnahmedatum
    data_hash_value(:epdwingolfbandaufnahmedate).try(:to_datetime) || data_hash_value(:epdwingolfbandverleihungdate).try(:to_datetime)
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
    str = strs.first
    
    # Es gibt Fälle, in denen sich nicht an die Syntax gehalten wurde. 
    # Diese müssen hier von Hand nachgebessert werden.
    #
    if str.present?
      str = str.gsub(" -durch ", " - durch ")
      str = str.gsub(/^ausgetreten durch /, " - ausgetreten - durch" )  # z.B. W54888 im Export 2012
      str = str.gsub(" - ausgetreten durch ", " - ausgetreten - durch ")  # z.B. W54888 im Export 2014
    end
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
  

  # Weitere Hinweis-Freitext-Felder
  # =======================================================================

  def freetext_descriptions
    descriptions_without_standard_format + netenv_org_descriptions
  end

  def netenv_org_descriptions
    data_hash_value(:epdorgdescription).try(:split, "|") || []
  end
  
  def descriptions_without_standard_format
    descriptions.select do |str|
      not str.include? " - durch "
    end
  end
  


  # Aktueller Status in den Verbindungen
  # =======================================================================
  
  def verbindungsstatus_ldap_assignments
    data_hash_value(:epddynagroupsstatus).try(:split, "|") || []
  end
  
  def dynamische_gruppen_ldap_assignments
    data_hash_value(:epddynagroups).try(:split, "|") || []
  end
  
  # Aus altem Import-Mechanismus:
  # 
  # def ldap_groups
  #   ldap_group_string = d('epddynagroups') 
  #   ldap_group_string += "|" + d('epddynagroupsstatus') if d('epddynagroupsstatus')
  #   ldap_assignments = ldap_group_string.split("|")
  #   ldap_group_paths = []
  #   ldap_assignments.each do |assignment| # assignment = "o=asd,ou=def"
  #     ldap_group_path = []
  #     ldap_category_assignments = assignment.split(",")
  #     ldap_category_assignments.each do |category_assignment|
  #       ldap_category, ldap_group = category_assignment.split("=")
  #       #ldap_group_path << { ldap_category => ldap_group }
  #       ldap_group_path << ldap_group
  #     end
  #     ldap_group_paths << ldap_group_path
  #   end
  #   ldap_group_paths
  # end
  

  # Beispiele für ldap_assignment:
  #   "o=E,o=Verbindungen,ou=groups,dc=wingolf,dc=org"
  #   "o=Verbindungen,ou=groups,dc=wingolf,dc=org"
  #   "ou=groups,dc=wingolf,dc=org"
  #   "o=wv_e_-_konkneipant,o=E,o=Verbindungen,ou=groups,dc=wingolf,dc=org"
  #   "o=E,o=Verbindungen,ou=groups,dc=wingolf,dc=org$$Konkneipant"
  #
  def ldap_assignments
    (dynamische_gruppen_ldap_assignments + verbindungsstatus_ldap_assignments).collect do |assignment|
      # Koe -> Kö, damit es auch erkannt wird. Beispiel: W65066
      assignment.gsub("o=Koe", "o=Kö")
    end
  end
  
  def last_known_status_in( corporation )
    assignments_in_corporation = ldap_assignments.select do |ldap_assignment|
      ldap_assignment.include?("o=#{corporation.token}") and not ldap_assignment.include?("erstbandtraeger")
    end
    
    status_names = assignments_in_corporation.collect do |assignment|
      match = assignment.match(/dc=org\$\$(.*)$/) || assignment.match(/^o=#{corporation.token},o=(Philister),/)
      match[1] if match
    end.select { |status_name| status_name != nil }
    
    # if assignments_in_corporation.count > 1
    #   pp assignments_in_corporation
    #   raise "Status assignment of user #{self.w_nummer} in corporation #{corporation.token} not unique."
    #   #
    #   # Offenbar aber gibt es Benutzer, die gleichzeitig als Aktiver und Inaktiver eingetragen sind.
    #   # Da ich annehme, dass hier vergessen wurde, eine Gruppe auszutragen, setze ich fest,
    #   # dass einfach die letzte Mitgliedschaft als gültig angesehen wird.
    #   # 
    #   # ["o=Hv,o=Verbindungen,ou=groups,dc=wingolf,dc=org$$Aktiver Bursch",
    #   # "o=Hv,o=Verbindungen,ou=groups,dc=wingolf,dc=org$$Inaktiver non-loci"]
    #   # Status assignment of user W64710 in corporation Hv not unique.
    #   #
    # end

    return status_names.last
  end
  
  def last_known_status_group_in( corporation )
    status_name = last_known_status_in( corporation )
    
    group_name = "Hospitanten" if status_name == "Hospitant"
    group_name = "Kraßfuxen" if status_name == "Fux" || status_name == "Kraßfux"
    group_name = "Brandfuxen" if status_name == "Brandfux"
    group_name = "Konkneipanten" if status_name == "Konkneipant"
    group_name = "Inaktive Burschen loci" if (status_name == "Inaktiver Bursch") or (status_name == "Inaktiver loci")
    group_name = "Inaktive Burschen non loci" if status_name == "Inaktiver non-loci"
    group_name = "Aktive Burschen" if status_name == "Aktiver Bursch"
    group_name ||= status_name
    
    status_group = corporation.status_group(group_name)
    raise "Status group '#{group_name}' not found for corporation '#{corporation.token}'." if status_name.present? and not status_group
    return status_group
  end


  # Bezirksverbände
  # =======================================================================
  
  def bv
    Bv.find_by_token(bv_token) if bv_token_ok?(bv_token)
  end
  
  def bv_token
    bv_token_from_ldap 
    #
    # Die übrigen Spalten sollen ignoriert werden, da diese zum Teil auch für Aktive gesetzt sind,
    # während nur Philister einem BV zugeordnet werden sollen:
    # 
    #   || data_hash_value(:epdwingolfbezirksverband) || data_hash_value(:epdregionalarea) || data_hash_value(:epdprofregionalarea)
  end
  
  def bv_token_from_ldap
    match = bv_ldap_assignment.match(/^o=(BV [0-9][0-9]),/) if bv_ldap_assignment
    match[1] if match
  end

  def bv_ldap_assignment
    # o=BV 22,o=BV,ou=groups,dc=wingolf,dc=org
    ldap_assignments.select do |assignment|
      assignment.match /,o=BV,/
    end.first
  end
  
  def bv_token_ok?(token)
    token.present? and token.match /^BV [0-9][0-9]$/
  end
  
  def angegebenes_bv_beitrittsdatum
    data_hash_value(:epdwingolfregionalareasincedate).try(:to_datetime) || data_hash_value(:epdwingolfbezverbandmembershipstart).try(:to_datetime)
  end
  
  def bv_beitrittsdatum
    angegebenes_bv_beitrittsdatum || philistrationsdatum || aktivmeldungsdatum
  end
  
  def bv_beitrittsdatum_geschätzt?
    not angegebenes_bv_beitrittsdatum.present?
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

    # Fix: W64301 hat einen (unsinnigen) Geburtstag angegeben, der nach dem Aktivmeldungsdatum liegt.
    # In diesem Fall wird die Schleife oben vollständig durchlaufen ohne `return`.
    #
    return "19#{yy}" if "20#{yy}" > Time.zone.now.year.to_s
    return "20#{yy}"
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
      last_name == "Geschäftsstelle des Wingolfs" or
      name == "Tphil Tphil" or 
      name == "testadmin testadmin" or
      w_nummer == "duser" or
      last_name == "Tester" or 
      last_name == "Testgjesdal" or
      last_name == "testadmin"
  end
  
  def duplicate_or_mistaken_user?
    #
    # Die Duplikate und fälschlicherweise angelegten Benutzer wurden in einem mehrstufigen Verfahren
    # ermittelt, teilweise durch telefonische Rückfrage.
    # 
    # Siehe: https://trello.com/c/Fv4eMohq/510-doppelte-user
    #
    w_nummer.in? ["W51007", "W64276", "W54116", "W54508", "W55062", "W64201", "W64485", "W64565", "W64598", "W64613", "W64926", "W64928", "W64991", "W64993", "W65192", "W65246", "W65257", "W65613", "W65693", "W65648"]
  end
  
end