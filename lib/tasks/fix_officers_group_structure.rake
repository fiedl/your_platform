
namespace :fix do

  require 'colored'

  desc "Find Officer group under Officer group or Admin group"
  task officers_group_structure: :environment do
    print "\nTask: Find Officer groups under an Officer group or an Admin group.\n".cyan
    puts "There are #{Group.find_all_by_flag( :officers_parent ).count} officer groups in total now."
    puts "There are #{Group.find_all_by_flag( :admins_parent ).count} admin groups in total now."

    num_of_officer_groups_under_officer_or_admin_group = 0

    Group.find_all_by_flag( :officers_parent ).each do |group|
      group.parents.each do |parent_group| 
        if parent_group.has_flag?( :officers_parent ) || 
           parent_group.has_flag?( :admins_parent )
          num_of_officer_groups_under_officer_or_admin_group += 1
          # Remove officer group  
          group.destroy
          print ".".red
        else
          print ".".green
        end
      end
    end
   
    puts ""
    puts "There are #{Group.find_all_by_flag( :officers_parent ).count} officer groups in total now."
    puts "There are #{Group.find_all_by_flag( :admins_parent ).count} admin groups in total now."
    print ( num_of_officer_groups_under_officer_or_admin_group.to_s + " Officer groups under Officer group or Admin group found and deleted.\n\n" ).green

  end
end


