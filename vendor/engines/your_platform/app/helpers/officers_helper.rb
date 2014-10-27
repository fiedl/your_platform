module OfficersHelper
  
  def sorted_officers_groups_for(structureable)
    structureable.find_officers_groups.sort_by do |group|
      [:main_admins, :admins].index(group.flags.first.try(:to_sym))
    end
  end
  
end