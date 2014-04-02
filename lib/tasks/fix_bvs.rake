namespace :fix do

  task :bvs => [
    'bvs:fix_assignments'
  ]
  
  namespace :bvs do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Fix BVs"
      log.info "Dieser Task führt Korrekturen bzgl. der Bezirksverbände durch."
      log.info ""
    end
    
    task :fix_assignments => [
      'environment',
      'requirements',
      'print_info',
      'assign_unassigned_philistres_to_bvs',
      'list_users_without_postal_address',
      'list_addresses_without_bv'
    ]
    
    task :assign_unassigned_philistres_to_bvs => [:environment, :requirements, :print_info] do
      log.section "Philister ohne BV-Zugehörigkeit einem BV zuordnen"
      log.info "Alle Philister sollten einem Bezirksverband zugeordnet sein. Philister ohne"
      log.info "eine solche Zuordnung einem BV anhand ihrer Postanschrift zuordnen."
      log.info ""
      log.info "Dies betrifft #{alle_philister_ohne_bv.count} Philister."
      log.info "Diese werden nun einem BV zugeordnet:"
      log.info ""

      for user in alle_philister_ohne_bv
        if user.alive? and user.wingolfit?
          print "#{user.w_nummer} ... "
          
          user.adapt_bv_to_postal_address
          
          if user && user.bv
            print "#{user.bv.token}\n"
          else
            if user.in? alle_benutzer_ohne_postanschrift
              log.warning "Keine Post-Anschrift!"
            else
              log.failure "konnte keinem BV zugeordnet werden. Kontrolle erforderlich!"
            end
          end
        end
      end
      
      log.success "Fertig."
    end
    
    task :list_users_without_postal_address => [:environment, :requirements, :print_info] do
      log.section "Wingolfiten ohne Postanschrift"
      log.info "Die folgenden Wingolfiten haben keine Postanschrift hinterlegt:"
      log.info ""
      
      for user in alle_benutzer_ohne_postanschrift
        if user.alive? and user.wingolfit?
          log.info "#{user.w_nummer}  #{user.title}"
        end
      end
    end
    
    task :list_addresses_without_bv => [:environment, :requirements, :print_info] do
      log.section "Adresse ohne BV-Zuordnung"
      log.info "Die folgenden Adressen können keinem BV zugeordnet werden."
      log.info ""
      log.info "Bitte fügen Sie entsprechende Zuordnungen mit Hilfe des Tasks"
      log.info "'rake import:bvs:additional_mappings' hinzu."
      log.info "Danach muss der Task 'rake fix:bvs' erneut ausgeführt werden.".yellow
      log.info ""
      
      for address_field in ProfileField.where(type: 'ProfileFieldTypes::Address')
        unless address_field.bv
          if address_field.plz
            address = address_field.value.gsub("\n", ", ")
            log.info "* PLZ #{address_field.plz} : #{address}"
          end
        end
      end
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
  def alle_philister
    User.joins_groups.where(:groups => {name: "Philister"}).uniq
  end
  
  def alle_bv_philister
    User.joins_groups.where(:groups => {name: "Bezirksverbände"}).uniq
  end
  
  def alle_philister_ohne_bv
    alle_philister - alle_bv_philister - [nil]
  end
  
  def alle_benutzer_ohne_postanschrift
    User.without_postal_address
  end
  
  def alle_benutzer_mit_postanschrift
    User.with_postal_address
  end
  
end

