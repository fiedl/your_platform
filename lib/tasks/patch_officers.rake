# Diese Task-Sammlung dient der Anpassung von Amtsträgerstrukturen
# an die aktuellen Anforderungen.
#
namespace :patch do
  task :officers => [
    'officers:seniores_und_schriftwarte_anlegen'
  ]
  
  namespace :officers do
    task :requirements do
      require 'importers/models/log'
    end
    task :print_info => [:requirements] do
      log.head "Patch Officers"
      log.info "Diese Task-Sammlung dient der Anpassung von Amtsträgerstrukturen"
      log.info "an die aktuellen Anforderungen."
    end
    
    task :seniores_und_schriftwarte_anlegen => [
      'wv_seniores_anlegen',
      'phv_vorsitzende_anlegen',
      'bv_leiter_anlegen',
      'schriftwarte_anlegen'
    ]
    
    task :schriftwarte_anlegen => [:environment, :print_info] do
      log.section "Amtsträger-Gruppen für Schriftwarte anlegen"
      log.info "Für alle WV, PhV und BV."
      wv_phv_and_bv_groups = Aktivitas.all + Philisterschaft.all + Bv.all
      counter = 0
      for group in wv_phv_and_bv_groups
        if not group.officers_parent
          print "\n"
          log.failure "Die Gruppe #{group.id} (#{group.extensive_name}, #{group.name}) besitzt keine Amtsträger-Obergruppe."
        else
          if not group.officers_parent.child_groups.find_by_flag(:schriftwart)
            schriftwart_group = group.officers_parent.child_groups.create(name: "Schriftwart")
            schriftwart_group.add_flag :schriftwart
                    
            counter += 1
            print ".".green
          end
        end
      end
      log.info ""
      log.success "#{counter} Schriftwart-Amtsträger-Gruppen angelegt."
    end
    task :wv_seniores_anlegen => [:environment, :print_info] do
      log.section "Seniores der Wingolfsverbindungen anlegen"
      counter = 0
      Aktivitas.all.each do |aktivitas|
        if not aktivitas.officers_parent.child_groups.find_by_flag(:senior)
          senior_group = aktivitas.officers_parent.child_groups.create(name: "Senior (x)")
          senior_group.add_flag :senior
          
          counter += 1
          print ".".green
        end
      end
      print "\n"
      log.success "#{counter} Senior-Amtsträger-Gruppen angelegt."
    end
    task :phv_vorsitzende_anlegen => [:environment, :print_info] do
      log.section "Vorsitzende der Philistervereine anlegen"
      counter = 0
      Philisterschaft.all.each do |philisterschaft|
        if not philisterschaft.officers_parent.child_groups.find_by_flag(:phil_x)
          vorsitzender_group = philisterschaft.officers_parent.child_groups.create(name: "Vorsitzender (Phil-x)")
          vorsitzender_group.add_flag :phil_x
          
          counter += 1
          print ".".green
        end
      end
      print "\n"
      log.success "#{counter} Phil-x-Amtsträger-Gruppen angelegt."
    end
    task :bv_leiter_anlegen => [:environment, :print_info] do
      log.section "Leiter der Bezirksverbände anlegen"
      counter = 0
      Bv.all.each do |bv|
        if not bv.officers_parent.child_groups.find_by_flag(:bv_leiter)
          leiter_group = bv.officers_parent.child_groups.create(name: "BV-Leiter")
          leiter_group.add_flag :bv_leiter
          
          counter += 1
          print ".".green
        end
      end
      print "\n"
      log.success "#{counter} BV-Leiter-Amtsträger-Gruppen angelegt."
    end
  end
  
  def log
    @log ||= Log.new
  end
end