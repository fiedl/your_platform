#
# This mixin adds methods to groups which are so called special groups,
# for example the `admins_parent` group, which contains all admin
# users of structureable objects.
#
module GroupMixins::MethodsForSpecialGroups

  extend ActiveSupport::Concern

  included do
  end

  # Officers somehow administrate structureable objects, e.g. groups or pages.
  # They may be admins, main_admins, editors or another kind of officer.
  #
  # This method returns the object that is administrated by the officers that are in this
  # group (self) if this is an officer group.
  #
  #     some_group
  #         |------- another_group   <---------------------------- this group is returned
  #                        |-------- officers
  #                                      |---- admins
  #                                               |--- main_admins
  #
  #     main_admins.administrated_object == another_group
  #     admins.administrated_object == another_group
  #     officers.administrated_object == another_group
  #     another_group.administrated_object == nil
  #     some_group.administrated_object == nil
  #
  def administrated_object
    if self.ancestor_groups.find_all_by_flag( :officers_parent ).count == 0 and
        not self.has_flag? :officers_parent
      return nil
    end
    object = self
    until object.has_flag? :officers_parent
      object = object.parents.first
    end
    object = object.parents.first
  end
  
end
