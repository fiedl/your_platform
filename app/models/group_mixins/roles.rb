#
# This mixin adds methods to special groups that are related to the role model.
#
module GroupMixins::Roles

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
    object = self
    counter = 0
    until object.has_flag?(:officers_parent)
      object = object.parents.first
      return nil if object.nil?
      counter += 1
      counter < 5 || raise('This, aparently is no admins group.')
    end
    object = object.parents.first
  end

end
