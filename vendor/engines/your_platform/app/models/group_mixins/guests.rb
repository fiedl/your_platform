#
# All groups have associated special groups, for example the `guests_parent` group, which
# contains all guests of the group. 
# 
# This mixin provides the accessor methods for the guests_parent special group.
#
# The mechanism used in the mixin is defined in `StructureableMixins::HasSpecialGroups`.
#
module GroupMixins::Guests

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end
  
  
  # Guests
  # ==========================================================================================

  def find_guests_parent_group
    find_special_group(:guests_parent)
  end

  def create_guests_parent_group
    create_special_group(:guests_parent)
  end

  def find_or_create_guests_parent_group
    find_or_create_special_group(:guests_parent)
  end

  def guests_parent
    find_or_create_guests_parent_group
  end

  def guests_parent!
    find_guests_parent_group || raise('special group :guests_parent does not exist.')
  end

  def find_guest_users
    guests_parent.descendant_users
  end

  def guests
    find_guest_users
  end

  # This method lists all guest subgroups of self, but not of the subgroups of self.
  # This is used, for example, if there are several kinds of guests.
  #
  #    my_group
  #        |---------- guests_parent
  #                       |----------- regular_guests    <-- returned by this
  #                       |----------- vip_guests        <-- method.
  #
  def find_guests_groups
    find_guests_parent_group.descendant_groups
  end
  
end  
