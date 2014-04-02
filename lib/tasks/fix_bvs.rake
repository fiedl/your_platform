namespace :fix do

  namespace :bvs do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Fix BVs"
      log.info "Dieser Task führt Korrekturen bzgl. der Bezirksverbände durch."
      log.info ""
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
end

