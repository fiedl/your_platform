namespace :patch do

  task :groups => [
    'groups:part1',
    'groups:part2'
  ]
  
  namespace :groups do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Group Patcher"
      log.info "Dieser Patch führt Korrekturen an den bereits importierten Gruppen durch."
      log.info ""
    end
    
    task :part1 => [
      'environment',
      'requirements',
      'print_info',
      'add_wingolf_super_groups',
      'recalculate_membership_validity_ranges_for_super_groups'
    ]
    
    task :part2 => [
      'full_members_flags'
    ]
    
    task :add_wingolf_super_groups => [:environment, :requirements, :print_info] do
      log.section "Wingolfs-Zusammenfassungs-Gruppen erstellen."
      log.info "Gesamtgruppen für alle Wingolfiten, alle Aktiven, alle Philister."
      log.info ""
      
      jeder = Group.find_everyone_group

      unless alle_wingolfiten = Group.find_by_flag(:alle_wingolfiten)
        alle_wingolfiten = jeder.child_groups.create name: "Alle Wingolfiten"
        alle_wingolfiten.add_flag :alle_wingolfiten
      end
      
      unless alle_aktiven = Group.find_by_flag(:alle_aktiven)
        alle_aktiven = alle_wingolfiten.child_groups.create name: "Alle Aktiven"
        alle_aktiven.add_flag :alle_aktiven
      end
      
      unless alle_philister = Group.find_by_flag(:alle_philister)
        alle_philister = alle_wingolfiten.child_groups.create name: "Alle Philister"
        alle_philister.add_flag :alle_philister
      end
      
      unless alle_verstorbenen_wingolfiten = Group.find_by_flag(:alle_verstorbenen_wingolfiten)
        alle_verstorbenen_wingolfiten = alle_wingolfiten.child_groups.create name: "Alle verstorbenen Wingolfiten"
        alle_verstorbenen_wingolfiten.add_flag :alle_verstorbenen_wingolfiten
      end

      log.info "Binde Korporationen ein:"
      for corporation in Corporation.find_all_wingolf_corporations
        print "#{corporation.name} "

        if corporation.aktivitas and not corporation.aktivitas.in? alle_aktiven.child_groups
          print "."
          alle_aktiven.child_groups << corporation.aktivitas
        else
          print ".".yellow
        end
        
        if corporation.philisterschaft and not corporation.philisterschaft.in? alle_philister.child_groups
          print "."
          alle_philister.child_groups << corporation.philisterschaft 
        else
          print ".".yellow
        end
        
        if corporation.verstorbene and not corporation.verstorbene.in? alle_verstorbenen_wingolfiten.child_groups
          print "."
          alle_verstorbenen_wingolfiten.child_groups << corporation.verstorbene 
        else
          print ".".yellow
        end

        print "\n"
      end
      
      log.success "Fertig."
    end
    
    task :recalculate_membership_validity_ranges_for_super_groups => [:environment, :requirements, :print_info] do
      log.section "Gültigkeitszeiträume für Mitgliedschaften in Zusammenfassungsgruppen neu berechnen."
      log.info "Wenn Gruppen-Beziehungen nachträglich hinzugefügt werden, müssen ggf. die Gültigkeitszeiträume neu abgeleitet werden."
      log.info ""

      groups = [
        Group.find_by_flag(:alle_wingolfiten),
        Group.find_by_flag(:alle_aktiven),
        Group.find_by_flag(:alle_philister)
      ]
      
      counter = 0
      User.find_each do |user|
        for group in groups
          membership = UserGroupMembership.with_invalid.find_by_user_and_group(user, group)
          if membership
            membership.recalculate_validity_range_from_direct_memberships!
            print ".".green
            counter += 1 
          else
            print "."
          end
        end
      end
      
      log.info ""
      log.success "#{counter} UserGroupMemberships aktualisiert."
    end
    
    task :full_members_flags => [:environment, :requirements, :print_info] do
      log.section "Aktivitas und Philisterschaft mit :full_members markieren"
      log.info "Damit wird ermittelt, ob eine Person ordentliches Mitglied einer"
      log.info "Verbindung ist."
      
      groups = 
        Group.find_by_flag(:alle_aktiven).child_groups +
        Group.find_by_flag(:alle_philister).child_groups -
        Group.find_all_by_flag(:officers_parent)
      
      groups.each do |group|
        group.add_flag :full_members
        print ".".green
      end
      
      log.info ""
      log.info "Fertig."
    end
  end
  
  def log
    $log ||= Log.new
  end
  
end

