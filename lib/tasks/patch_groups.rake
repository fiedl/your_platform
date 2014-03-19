namespace :patch do

  task :groups => [
    'groups:part1'
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
      'add_wingolf_super_groups'
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
      
      for corporation in [Corporation.find_by_token("Be")]
        log.info corporation.name

        if corporation.aktivitas
          alle_aktiven << corporation.aktivitas 
          for user in corporation.aktivitas.descendant_users
          #   UserGroupMembership.with_invalid.find_by_user_and_group(user, alle_aktiven).recalculate_validity_range_from_direct_memberships
          #   UserGroupMembership.with_invalid.find_by_user_and_group(user, alle_wingolfiten).recalculate_validity_range_from_direct_memberships
            Rails.cache.delete [current_user, "my_groups_table"]
            print "."
          end
        end

        if corporation.philisterschaft
          alle_philister << corporation.philisterschaft
          # for user in corporation.philisterschaft.descendant_users
          #   UserGroupMembership.with_invalid.find_by_user_and_group(user, alle_philister).recalculate_validity_range_from_direct_memberships
          #   UserGroupMembership.with_invalid.find_by_user_and_group(user, alle_wingolfiten).recalculate_validity_range_from_direct_memberships
          #   print "."
          # end
        end
        print "\n"
      end
      
      log.success "Fertig."
    end

  end
  
  def log
    $log ||= Log.new
  end
  
end

