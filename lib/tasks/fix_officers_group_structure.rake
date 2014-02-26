namespace :fix do
  
  task :officers => [
    'environment',
    'officers:requirements',
    'officers:print_info',
    'officers:group_structure',
    'officers:remove_empty_officers_parents'
  ]
  
  namespace :officers do
    
    task :requirements do
      require 'importers/models/log'
      require 'colored'
    end
        
    task :print_info => [:requirements] do
      log.head "Officers Fix"
      log.info "Dieser Task behebt Fehler im Zusammenhang mit Amtsträgern."
      log.info ""
    end
    
    desc "Remove empty officers groups under officers groups or admin groups"
    task :group_structure => [:environment, :requirements] do
      log.section "Gruppen-Struktur"
      log.info "Entferne verschachtelte Strukturen, in denen Amtsträger-Gruppen direkt"
      log.info "unter Amtsträger-Gruppen angelegt wurden."
      log.info ""

      log.info "There are #{Group.find_all_by_flag( :officers_parent ).count} officer groups in total now."
      log.info "There are #{Group.find_all_by_flag( :admins_parent ).count} admin groups in total now."
      num_of_officer_groups_under_officer_or_admin_group = 0

      Group.find_all_by_flag(:officers_parent).each do |group|
        group.parents.each do |parent_group| 
          if parent_group.has_flag?(:officers_parent) or parent_group.has_flag?(:admins_parent)

            num_of_officer_groups_under_officer_or_admin_group += 1
            group.destroy
            print "!".green
          else
            print "."
          end
        end
      end
      
      log.info ""
      log.info ""
      log.info "There are #{Group.find_all_by_flag( :officers_parent ).count} officer groups in total now."
      log.info "There are #{Group.find_all_by_flag( :admins_parent ).count} admin groups in total now."
      log.success "#{num_of_officer_groups_under_officer_or_admin_group} bad officer groups found and deleted."
    end
    
    desc "Remove officers_parent groups without descendant users (i.e. members and former members)."
    task :remove_empty_officers_parents => [:environment, :requirements] do
      log.section "Entferne leere Amtsträger-Gruppen"
      log.info "Amtsträger-Sammelgruppe ohne jetzige oder ehemalige Mitglieder können"
      log.info "gelöscht werden -- einschließlich ihrere Untergruppen."
      log.info ""
      
      counter = 0
      Group.find_all_by_flag(:officers_parent).each do |officers_parent_group|
        if officers_parent_group.descendant_users.count == 0
          officers_parent_group.descendant_groups.each do |descendant_group|

            print ":".yellow
            descendant_group.destroy
          end

          officers_parent_group.destroy
          print "!".yellow
          counter += 1
        else
          print "."
        end
      end
      
      log.info ""
      log.info ""
      log.success "#{counter} leere Amtsträger-Gruppen entfernt." 
    end

  end
  
  # Former task name:
  task :officers_group_structure => 'officers:group_structure'

end


