module OfficersHelper
  
  def sorted_officers_groups_for(structureable)
    sort_officer_groups(structureable.find_officers_groups)
  end
  
  def sort_officer_groups(officer_groups)
    officer_groups.sort_by do |group|
      [:senior, :fuxmajor, :kneipwart, :phil_x, :schriftwart, 
        :kassenwart, 
        :alle_seniores, :alle_fuxmajores, :alle_kneipwarte,
        :main_admins, :main_admins_parent, 
        :admins, :admins_parent, :chargen]
        .index(group.flags.first.try(:to_sym)) || (100 + group.id)
    end
  end
  
end