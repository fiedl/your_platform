# 
# A StatusGroup is a sub-Group of a Corporation that memberships model the 
# current status of members within the corporation.
#
# At present time, the status of a user within a corporation is unique.
#
class StatusGroup < Group
  
  def self.find_all_by_corporation(corporation)
    corporation.cached(:leaf_groups)
  end
  
  def self.find_all_by_user(user, options = {})
    user_groups = options[:with_invalid] ? user.ancestor_groups : user.groups
    user.cached(:corporations).collect do |corporation|
      StatusGroup.find_all_by_corporation(corporation)
    end.flatten & user_groups
  end
  
  def self.find_by_user_and_corporation(user, corporation)
    status_groups = (StatusGroup.find_all_by_corporation(corporation) & user.groups)
    raise 'selection algorithm not unique, yet. Please correct this.' if status_groups.count > 1
    status_groups.last
  end
  
end
