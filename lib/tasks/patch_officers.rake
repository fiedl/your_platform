# Diese Task-Sammlung dient der Anpassung von Amtsträgerstrukturen
# an die aktuellen Anforderungen.
#
namespace :patch do
  task :officers => [
    'officers:flags_ergaenzen',
    'officers:aemter_umbenennen',
    'officers:aemter_anlegen',
    'officers:chargen_in_chargengruppe_schieben',
    'officers:admins_anlegen'
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
    
    task :flags_ergaenzen => [:environment, :print_info] do
      log.section "Flags für bestehenden Ämter-Gruppen ergänzen"
      Group.where(name: ['Senior', 'Senior (x)']).each { |group| group.add_flag :senior }
      Group.where(name: ['Fuxmajor', 'Fuxmajor (xx)']).each { |group| group.add_flag :fuxmajor }
      Group.where(name: ['Fuxmajor', 'Fuxmajor (xx)']).each { |group| group.add_flag :senior }
      Group.where(name: ['Consenior']).each { |group| group.add_flag :consenior }
    end
    
    task :aemter_umbenennen => [:environment, :print_info] do
      log.section "Mehrdeutige Ämter umbenennen"
      log.info "-> Kassenwarte"
      Group.where(name: 'Kassenwart').each do |group|
        group.name = 'Hauptkassenwart' if group.ancestor_groups.include? Group.alle_aktiven
        group.name = 'Philister-Kassenwart' if group.ancestor_groups.include? Group.alle_philister
        group.name = 'BV-Kassenwart' if group.ancestor_groups.include? Group.bvs_parent
        group.save
      end
      log.info "-> Schriftwarte"
      Group.where(name: 'Schriftwart').each do |group|
        group.name = 'Philister-Schriftwart' if group.ancestor_groups.include? Group.alle_philister
        group.name = 'Philister-Kassenwart' if group.ancestor_groups.include? Group.bvs_parent
        group.save
      end
      log.info "-> Philister-x"
      Group.where(name: 'Vorsitzender (Phil-x)').each do |group|
        group.name = 'Philister-x'
        group.save
      end
    end
    
    task :aemter_anlegen => [:environment, :print_info] do
      
      aemterstruktur = {
        wv: {chargen: {senior: 'Senior (x)', fuxmajor: 'Fuxmajor (xx)', kneipwart: 'Kneipwart (xxx)'}, 
          schriftwart: 'Schriftwart', kassenwart: 'Hauptkassenwart'},
        phv: {phil_x: 'Philister-x', schriftwart: 'Philister-Schriftwart', 
          kassenwart: 'Philister-Kassenwart'},
        bv: {bv_leiter: 'BV-Leiter', schriftwart: 'BV-Schriftwart', 
          kassenwart: 'BV-Kassenwart'}
      }
      
      log.section "Ämterstrukturen für Activitates anlegen"
      aemterstruktur_anlegen Aktivitas.all, aemterstruktur[:wv]

      log.section "Ämterstrukturen für Philisterschaften anlegen"
      aemterstruktur_anlegen Philisterschaft.all, aemterstruktur[:phv]

      log.section "Ämterstrukturen für Bezirksverbände anlegen"
      aemterstruktur_anlegen Bv.all, aemterstruktur[:bv]
      
    end
    
    def aemterstruktur_anlegen(groups, aemterstruktur)
      groups.each do |group|
        print "-> #{group.corporation.try(:name)} -> #{group.name}\n".green
        if group.officers_parent
          aemterstruktur.each do |flag, name_or_subgroups|
            if group.officers_parent.descendant_groups.find_all_by_flag(flag).count == 0
              name = name_or_subgroups.kind_of?(String) ? name_or_subgroups : flag.to_s.camelize
              print "  -> #{name} (:#{flag})\n".blue
              officer_group = group.officers_parent.child_groups.create name: name
              officer_group.add_flag flag
              if name_or_subgroups.kind_of?(Hash)
                name_or_subgroups.each do |flag, name|
                  if group.officers_parent.descendant_groups.find_all_by_flag(flag).count == 0
                    print "    -> #{name} (:#{flag})\n".blue
                    subgroup = officer_group.child_groups.create name: name
                    subgroup.add_flag flag
                  else
                    print "    -> :#{flag} bereits vorhanden\n".yellow
                  end
                end
              end
            else
              print "  -> :#{flag} bereits vorhanden.\n".yellow
            end
          end
        end
      end
    end
    
    task :chargen_in_chargengruppe_schieben => [:environment, :print_info] do
      log.section "Chargen-Ämter in Obergruppe 'Chargen' verschieben"
      Corporation.all.each do |corporation|
        print "-> #{corporation.name}\n".green
        
        chargen = corporation.descendant_groups.find_by_flag :chargen
        consenior = corporation.descendant_groups.find_by_flag :consenior
        senior = corporation.descendant_groups.find_by_flag :senior
        fuxmajor = corporation.descendant_groups.find_by_flag :fuxmajor
        kneipwart = corporation.descendant_groups.find_by_flag :kneipwart
        
        if senior and not senior.parent_groups.include? chargen
          print "   -> Senior\n".blue
          senior.move_to chargen
        end
        if consenior and not consenior.parent_groups.include? chargen
          print "   -> Consenior\n".blue
          consenior.move_to chargen
        end
        if fuxmajor and not fuxmajor.parent_groups.include? chargen
          print "   -> Fuxmajor\n".blue
          fuxmajor.move_to chargen
        end
        if kneipwart and not kneipwart.parent_groups.include? chargen
          print "   -> Kneipwart\n".blue
          kneipwart.move_to chargen
        end
      end
    end
    
    task :admins_anlegen => [:environment, :print_info] do
      log.section "Admin-Gruppen anlegen"
      [Corporation.all + Aktivitas.all + Philisterschaft.all + Bv.all].flatten.each do |group|
        print "-> #{group.name}\n".green
        group.admins
      end
    end

  end
  
  def log
    @log ||= Log.new
  end
end