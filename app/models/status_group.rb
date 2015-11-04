# 
# A StatusGroup is a sub-Group of a Corporation that memberships model the 
# current status of members within the corporation.
#
# At present time, the status of a user within a corporation is unique.
#
class StatusGroup < Group
  
  def self.find_all_by_corporation(corporation)
    corporation.connected_leaf_groups
  end
  
  def self.find_all_by_user(user, options = {})
    user_groups = options[:with_invalid] ? user.parent_groups : user.direct_groups
    user.corporations.collect do |corporation|
      StatusGroup.find_all_by_corporation(corporation)
    end.flatten & user_groups.to_a
  end
  
  def self.find_by_user_and_corporation(user, corporation)
    status_groups = (StatusGroup.find_all_by_corporation(corporation) & StatusGroup.find_all_by_user(user))
    raise "Slection algorithm not unique, yet. Please correct this. Found possible status groups: #{status_groups.map(&:name).join(', ')}." if status_groups.count > 1
    status_groups.last
  end
  
end
