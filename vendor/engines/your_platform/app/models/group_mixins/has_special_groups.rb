module GroupMixins::HasSpecialGroups

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end
  
  
  
  # Guests Parent
  # ==========================================================================================
  #
  # As well as officers, each group may have guests.
  #

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

  def guests
    guests_parent.descendant_users
  end
  
    # Guests Parent
  # ==========================================================================================

  # This method lists all guest sub-groups of self, but not of the sub-groups of self.
  #
  def find_guests_groups
    find_guests_parent_group.descendant_groups
  end

  # This method lists all descendant users of the guests_parent_group.
  #
  def find_guest_users
    guests
  end
  
end  
