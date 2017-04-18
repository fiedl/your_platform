class Groups::GroupOfGroups < Group

  def child_groups_table_rows
    child_groups.regular.collect do |child_group|
      hash = {child_group_id: child_group.id, members_count: child_group.members.count}
      important_officer_keys.each do |key|
        hash["#{key}_ids"] = child_group.descendant_groups.flagged(key).first.try(:members).try(:pluck, :id) || []
      end
      hash
    end
  end

  def important_officer_keys
    Flag.where(flagable_type: "Group", flagable_id: descendant_groups.where(type: "OfficerGroup").pluck(:id)).pluck(:key).uniq
  end

  cache :child_groups_table_rows if use_caching?
end