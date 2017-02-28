concern :UserGroups do

  # If the user's groups need to be split up into categories,
  # this method is handy. It returns the user's group ids as hash
  # of categories:
  #
  #     {
  #       category1 => group_ids,
  #       category2 => group_ids,
  #       "other" => group_ids
  #     }
  #
  def group_ids_by_category
    hash = {}
    sorted_current_corporations.each do |corporation|
      hash[corporation.title] = [corporation.id] + (corporation.groups & self.groups.regular).map(&:id)
    end
    hash[:other] = groups.regular.pluck(:id) - Group.corporations_parent.descendant_group_ids
    return hash
  end

end