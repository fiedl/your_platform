#
# This module contains the extensions of the Group model that concern officers groups. 
# 
# Note that the majority of the officers functionality is handled by the Structureable model,
# since officers groups can be also assigned to Pages etc. and not only to Groups.
#
# See: 
#   * app/models/structureable_mixins/roles.rb
#   * app/models/structureable_mixins/has_special_groups.rb
#
module GroupMixins::Officers

  extend ActiveSupport::Concern

  included do
  end
  
  # This method determines if the group has no subgroups other than the officers
  # special group. This is used to determine whether the group is a status group.
  # 
  def has_no_subgroups_other_than_the_officers_parent?
    (self.child_groups.count == 0) or
      ((self.child_groups.count == 1) and (self.child_groups.first.has_flag?(:officers_parent)))
  end
  
  # This method determines if the group is an officers group.
  #
  def is_officers_group?
    self.ancestor_groups.each do |group|
      return true if group.has_flag? :officers_parent
    end
    return false
  end
  
end