# This extends the your_platform officers helper.
require_dependency YourPlatform::Engine.root.join('app/helpers/officers_helper').to_s

module OfficersHelper
  
  def sort_officer_groups(officer_groups)
    officer_groups.sort_by do |group|
      officer_group_sort_score(group)
    end
  end
  
  # This group determines the sort order of officer groups
  # in the officers box.
  #
  def officer_group_sort_score(group)
    flag = group.flags.first.try(:to_sym)
    #
    # Ganz oben stehen die Chargen, Philister-x, Schriftwart und 
    # Kassenwart.
    # 
    [:senior, :fuxmajor, :kneipwart, :phil_x, :schriftwart, :kassenwart, 
    :alle_seniores, :alle_fuxmajores, :alle_kneipwarte]
    .index(flag) ||
    #
    # Ganz unten stehen die Administratoren und die Chargen-Definition.
    # (Letztere ist die Chargen-Gruppe, die die Einzel-Chargen enthält.)
    #
    [:chargen, :main_admins, :main_admins_parent, :admins, :admins_parent]
    .index(flag).try(:+, 2e6) ||
    #
    # Dazwischen kommen alle übrigen Ämter.
    #
    (group.id + 1e6)
  end
  
end