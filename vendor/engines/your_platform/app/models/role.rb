# Example:
# 
#   Role.of(user).in(corporation).to_s    #  => "guest"
#   Role.of(user).in(corporation).guest?  #  => true
#   Role.find_all_by_user_and_group(user, corporation)
#
class Role
  
  def initialize(given_user, given_group)
    @user = given_user
    @group = given_group
  end
  
  # Example:
  # 
  #   Role.of(user).in(corporation).to_s  #  => "guest"
  #
  def self.of(given_user)
    self.new(given_user, nil)
  end

  # Example:
  # 
  #   Role.of(user).in(corporation).to_s  #  => "guest"
  #
  def in(given_group)
    @group = given_group
    return self
  end
  
  def user
    @user || raise('User not given, when trying to determine Role.')
  end
  
  def group
    @group || raise('Group not given, when trying to determine Role.')
  end
  
  def current_member?
    member? && full_member?
  end
  
  def full_member?
    (([group] + group.descendant_groups) & user.groups.find_all_by_flag(:full_members)).count > 0
  end
    
  def member?
    user.member_of? group
  end
  
  def guest?
    user.guest_of? group
  end
  
  def former_member?
    group.corporation? and user.former_member_of_corporation?(group)
  end
  
  
  
  # This finder method returns all global admins.
  #
  def self.global_admins
    Group.find_everyone_group.try(:find_admins) || []
  end
  
end