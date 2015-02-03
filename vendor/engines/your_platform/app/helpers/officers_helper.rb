module OfficersHelper
  
  def sorted_officers_groups_for(structureable)
    sort_officer_groups(structureable.find_officers_groups)
  end
  
  def sort_officer_groups(officer_groups)
    officer_groups.sort_by do |group|
      [:main_admins, :admins].index(group.flags.first.try(:to_sym)) || (100 + group.id)
    end
  end
  
end