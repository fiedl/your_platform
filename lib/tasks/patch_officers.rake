# Diese Task-Sammlung dient der Anpassung von Amtsträgerstrukturen
# an die aktuellen Anforderungen.
#

namespace :patch do
  task :officers => [                                                                                                  
    'officers:flags_ergaenzen',
    'officers:aemter_umbenennen',
    'officers:aemter_anlegen',
    'officers:chargen_in_chargengruppe_schieben',
    'officers:admins_anlegen',
    'officers:vereinigungsgruppen',
    'officers:vereinigungsgruppen_benennen',
    'officers:recalculate_memberships'
  ]
  
  namespace :officers do
    task :requirements => [:environment] do
      require 'importers/models/log'
      Aktivitas
      Philisterschaft
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
        group.name = 'Philister-Kassenwart' if group.ancestor_groups.philisterschaften.count > 0
        group.name = 'BV-Kassenwart' if group.ancestor_groups.include? Group.bvs_parent
        group.save
      end
      log.info "-> Schriftwarte"
      Group.find_by_flag(:alle_philister).descendant_groups.where(name: 'Schriftwart').each do |group|
        group.update_attributes name: 'Philister-Schriftwart'
      end
      Group.bvs_parent.descendant_groups.where(name: 'Schriftwart').each do |group|
        group.update_attributes name: 'BV-Schriftwart'
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
          kassenwart: 'BV-Kassenwart'},
        fuxia: {fuxen_x: 'Fuxen-x'}
      }
      
      log.section "Ämterstrukturen für Activitates anlegen"
      aemterstruktur_anlegen Aktivitas.all, aemterstruktur[:wv]
      aemterstruktur_anlegen (Aktivitas.all.collect { |a| a.descendant_groups.where(name: 'Fuxen').first }), aemterstruktur[:fuxia]

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
                  if group.officers_parent.descendant_groups.find_all_by_flag(flag).count == 0 and (group.corporation.nil? || group.corporation.descendant_groups.find_all_by_flag(flag).count == 0)
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
        print "-> #{group.corporation.try(:name)} -> #{group.name}\n".green
        group.admins
      end
    end
    
    task :vereinigungsgruppen => [:environment, :print_info] do
      log.section "Vereinigungsgruppen anlegen (Alle Chargierten, etc.)"                                      

      log.info "Jeder"
      Group.everyone

      log.info "  | "           
      log.info "Alle Wingolfiten"
      Group.alle_wingolfiten.move_to Group.everyone
      
      log.info "  |"
      log.info "  |--- Alle Aktiven"
      Group.alle_aktiven.move_to Group.alle_wingolfiten
      if Group.alle_aktiven.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_aktiven << aktivitas }
      end
      
      log.info "  |--- Alle Philister"
      Group.alle_philister.move_to Group.alle_wingolfiten
      if Group.alle_philister.descendant_users.count == 0
        Philisterschaft.all.each { |philisterschaft| Group.alle_philister << philisterschaft }
      end
      
      log.info "  |"
      log.info "  |--- Alle Amtsträger"
      Group.alle_amtstraeger
      
      log.info "         |"
      log.info "         |---- Alle Verbindungsamtsträger"
      Group.alle_wv_amtstraeger
      
      log.info "         |                   |------- Alle Chargierten"
      Group.alle_chargierten
      Group.alle_seniores
      Group.alle_fuxmajores
      Group.alle_kneipwarte
      if Group.alle_chargierten.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_chargierten << aktivitas.descendant_groups.find_by_flag(:chargen) }
      end
      
      log.info "         |                   |               |------- Alle Seniores"
      if Group.alle_seniores.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_seniores << aktivitas.descendant_groups.find_by_flag(:senior) }
        Group.alle_seniores << Group.find_by_flag(:bundes_x) if Group.find_by_flag(:bundes_x)
      end
      
      log.info "         |                   |               |------- Alle Fuxmajores"
      if Group.alle_fuxmajores.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_fuxmajores << aktivitas.descendant_groups.find_by_flag(:fuxmajor) }
      end
      
      log.info "         |                   |               |------- Alle Kneipwarte"
      if Group.alle_kneipwarte.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_kneipwarte << aktivitas.descendant_groups.find_by_flag(:kneipwart) if aktivitas.descendant_groups.find_by_flag(:kneipwart) }
      end
      
      log.info "         |                   |               |------- + Bundeschargierte"
      if Group.find_by_flag(:bundeschargen) and not Group.find_by_flag(:bundeschargen).parent_groups.include?(Group.alle_chargierten)
        Group.alle_chargierten << Group.find_by_flag(:bundeschargen)
      end
      
      log.info "         |                   |"
      log.info "         |                   |------- Alle Aktiven-Schriftwarte"
      Group.alle_wv_schriftwarte
      if Group.alle_wv_schriftwarte.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_wv_schriftwarte << aktivitas.descendant_groups.find_by_flag(:schriftwart) }
        Group.alle_wv_schriftwarte << Group.find_by_flag(:bundes_xx) if Group.find_by_flag(:bundes_xx)
      end
      
      log.info "         |                   |------- Alle Aktiven-Kassenwarte"
      Group.alle_wv_kassenwarte
      if Group.alle_wv_kassenwarte.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_wv_kassenwarte << aktivitas.descendant_groups.find_by_flag(:kassenwart) }
        Group.alle_wv_kassenwarte << Group.find_by_flag(:bundes_xxx) if Group.find_by_flag(:bundes_xxx)
      end

      log.info "         |                   |------- Alle Fuxen-Seniores"
      Group.alle_fuxen_seniores
      if Group.alle_fuxen_seniores.descendant_users.count == 0
        Aktivitas.all.each { |aktivitas| Group.alle_fuxen_seniores << aktivitas.descendant_groups.find_by_flag(:fuxen_x) }
      end

      log.info "         |                   |------- + alle übrigen WV-Amtsträger"
      Aktivitas.all.each do |aktivitas|
        if not aktivitas.officers_parent.in? Group.alle_wv_amtstraeger.child_groups
          Group.alle_wv_amtstraeger << aktivitas.officers_parent
        end
      end
      
      log.info "         |"
      log.info "         |---- Alle PhV-Amtsträger"
      Group.alle_phv_amtstraeger
      
      log.info "         |               |------------- Alle Phil-x"
      Group.alle_phv_vorsitzende
      if Group.alle_phv_vorsitzende.descendant_users.count == 0
        Philisterschaft.all.each { |philisterschaft| Group.alle_phv_vorsitzende << philisterschaft.descendant_groups.find_by_flag(:phil_x) }
      end
      
      log.info "         |               |------------- Alle Phil-Schriftwarte"
      Group.alle_phv_schriftwarte
      if Group.alle_phv_schriftwarte.descendant_users.count == 0
        Philisterschaft.all.each { |philisterschaft| Group.alle_phv_schriftwarte << philisterschaft.descendant_groups.find_by_flag(:schriftwart) }
      end
      
      log.info "         |               |------------- Alle Phil-Kassenwarte"
      Group.alle_phv_kassenwarte
      if Group.alle_phv_kassenwarte.descendant_users.count == 0
        Philisterschaft.all.each { |philisterschaft| Group.alle_phv_kassenwarte << philisterschaft.descendant_groups.find_by_flag(:kassenwart) }
      end
      
      log.info "         |"
      log.info "         |---- Alle BV-Amtsträger"
      Group.alle_bv_amtstraeger
      
      log.info "         |               |------------- Alle BV-Leiter"
      Group.alle_bv_leiter
      if Group.alle_bv_leiter.descendant_users.count == 0
        Bv.all.each { |bv| Group.alle_bv_leiter << bv.descendant_groups.find_by_flag(:bv_leiter) if bv.descendant_groups.find_by_flag(:bv_leiter)}
      end
      
      log.info "         |               |------------- Alle BV-Schriftwarte"
      Group.alle_bv_schriftwarte
      if Group.alle_bv_schriftwarte.descendant_users.count == 0
        Bv.all.each { |bv| Group.alle_bv_schriftwarte << bv.descendant_groups.find_by_flag(:schriftwart) if bv.descendant_groups.find_by_flag(:schriftwart)}
      end
      
      log.info "         |               |------------- Alle BV-Kassenwarte"
      Group.alle_bv_kassenwarte
      if Group.alle_bv_kassenwarte.descendant_users.count == 0
        Bv.all.each { |bv| Group.alle_bv_kassenwarte << bv.descendant_groups.find_by_flag(:kassenwart) if bv.descendant_groups.find_by_flag(:kassenwart) }
      end
      
      log.info "         |"
      log.info "         |---- Alle Vorsitzenden (Seniores, Phil-x, BV-Leiter, Bundes-x, VAW-x)"
      Group.alle_vorsitzenden
      if Group.alle_vorsitzenden.descendant_users.count == 0
        Group.alle_vorsitzenden << Group.alle_seniores
        Group.alle_vorsitzenden << Group.alle_phv_vorsitzende
        Group.alle_vorsitzenden << Group.alle_bv_leiter
        Group.alle_vorsitzenden << Group.find_by_flag(:bundes_x) if Group.find_by_flag(:bundes_x)
        Group.alle_vorsitzenden << Group.find_by_flag(:vaw_x) if Group.find_by_flag(:vaw_x)
      end
      
      log.info "         |---- Alle Schriftwarte (Schriftwarte + Bundes-xx + GfdW)"
      Group.alle_schriftwarte
      if Group.alle_schriftwarte.descendant_users.count == 0
        Group.alle_schriftwarte << Group.alle_wv_schriftwarte
        Group.alle_schriftwarte << Group.alle_phv_schriftwarte
        Group.alle_schriftwarte << Group.alle_bv_schriftwarte
        Group.alle_schriftwarte << Group.find_by_flag(:bundes_xx) if Group.find_by_flag(:bundes_xx)
        Group.alle_schriftwarte << Group.find_by_flag(:gfdw) if Group.find_by_flag(:gfdw)
      end

      log.info "         |---- Alle Kassenwarte  (Kassenwarte + Bundes-xxx + GfdW)"
      Group.alle_kassenwarte
      if Group.alle_kassenwarte.descendant_users.count == 0
        Group.alle_kassenwarte << Group.alle_wv_kassenwarte
        Group.alle_kassenwarte << Group.alle_phv_kassenwarte
        Group.alle_kassenwarte << Group.alle_bv_kassenwarte
        Group.alle_kassenwarte << Group.find_by_flag(:bundes_xxx) if Group.find_by_flag(:bundes_xxx)
        Group.alle_kassenwarte << Group.find_by_flag(:gfdw) if Group.find_by_flag(:gfdw)
      end

      log.info "    "
    end
    
    task :recalculate_memberships => [:requirements, :print_info] do
      log.section "Gültigkeitszeitraum für indirekte Mitgliedschaften berechnen"
      alle_vereinigungsgruppen.each do |group|
        print "#{group.flags.first} ... "
        group.calculate_validity_range_of_indirect_memberships
        print "ok.\n"
      end
    end
    
    task :vereinigungsgruppen_benennen => [:requirements, :print_info] do
      log.section "Vereinigungsgruppen benennen"
      alle_vereinigungsgruppen.each do |group|
        if group.read_attribute(:name) == group.flags.first.to_s
          group.name = I18n.t(group.flags.first, default: '')
          log.info ":#{group.flags.first} -> #{group.name}"
          group.save
        end
      end
    end
  end
  
  def alle_vereinigungsgruppen
    [
      Group.alle_wingolfiten,
      Group.alle_wingolfiten,
      Group.alle_aktiven,
      Group.alle_philister,
      Group.alle_amtstraeger,
      Group.alle_wv_amtstraeger,
      Group.alle_phv_amtstraeger,
      Group.alle_bv_amtstraeger,
      Group.alle_vorsitzenden,
      Group.alle_schriftwarte,
      Group.alle_kassenwarte,
      Group.alle_chargierten,
      Group.alle_seniores,
      Group.alle_fuxmajores,
      Group.alle_kneipwarte,
      Group.alle_wv_schriftwarte,
      Group.alle_wv_kassenwarte,
      Group.alle_fuxen_seniores,
      Group.alle_phv_vorsitzende,
      Group.alle_phv_schriftwarte,
      Group.alle_phv_kassenwarte,
      Group.alle_bv_leiter,
      Group.alle_bv_schriftwarte,
      Group.alle_bv_kassenwarte
    ]
  end
  
  def log
    @log ||= Log.new
  end
end