
# This module extends the Structureable models by methods for the interaction with roles.
# For example, a structureable object is being equipped with a `admins` association
# that lists all (direct) admin users of the object. To make a user an admin of a structureable
# object, you may call `object.admins << user`.
#
# This module is included by `include StructureableMixins::Roles`.
#
module StructureableMixins::Roles

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end


  module ClassMethods
  end


  # Admins
  # ==========================================================================================

  def admins_parent
    self.find_admins_parent_group
  end

  def admins_parent!
    p = admins_parent 
    p ||= self.create_admins_parent_group
    p
  end

  def find_admins_parent_group
    self.descendant_groups.find_by_flag( :admins_parent )
  end

  def create_admins_parent_group
    admins_parent_group = Group.create( name: I18n.t( :admins ) )
    admins_parent_group.add_flag( :admins_parent )
    admins_parent_group.save
    self.officers_parent!.child_groups << admins_parent_group
  end

  # This method allows you to list, add or remove direct admins of this object.
  # You may call:
  # 
  #   object.admins           # => []
  #   object.admins << user   
  #   object.admins.delete( user )
  #
  def admins
    self.admins_parent!.child_users
  end


end
