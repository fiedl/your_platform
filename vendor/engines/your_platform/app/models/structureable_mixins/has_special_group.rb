# -*- coding: utf-8 -*-

# This module extends the Structureable models by methods for the interaction with special_groups 
# that are descendants of the structureable object. 
# 
# For example, 
# 
#     class Page 
#       is_structureable ...
#       has_special_group :officers_parent
#     end
# 
# will give you these and other instance methods:
# 
#     some_page.officers # => Array of descendant_users of the officers_parent child_group 
#     some_page.find_officers_parent_group
#     some_page.create_officers_parent_group
#     some_page.officers_parent
#     some_page.officers_parent!
#
module StructureableMixins::HasSpecialGroup

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # This method creates the accessor methods corresponding to the given group flag.
    # See, description of StructureableMixins::HasSpecialGroup.
    #
    def has_special_group( group_flag, options = {} )    # ACHTUNG: def child_of ÜBERSPEICHERT JEDESMAL DIE SELBE METHODE.
      self.class_eval <<-EOL
        def flag_of_parent_of_#{group_flag}
          '#{options[ :child_of ]}'.to_sym
        end
        def find_#{group_flag}_group
          find_special_group( '#{group_flag}'.to_sym )
        end
      EOL
    end

  end
 
  # This method finds the group of all descendant_groups of this object that matches
  # the given flag.
  #
  def find_special_group( group_flag )
    self.descendant_groups.find_by_flag( group_flag )
  end

  # This method finds or creates the parent of the special_group specified
  # by the group_flag. 
  #
  # First priority for finding the parent group has the options[ :child_of ] parameter.
  # Second priority has the :child_of parameter given during `has_special_group ...`.
  # If none is found, `self` is returned, i.e. the special_group is a direct child
  # of the structureable object itself in this case.
  #
  def find_or_create_special_group_parent_for( group_flag )
    if self.respond_to? ( 'flag_of_parent_of_' + group_flag.to_s ).to_sym 
      child_of self.find_or_create_special_group( self.send( ( 'flag_of_parent_of_' + group_flag.to_s ).to_sym ) )
    end
    child_of ||= self
  end

  # This method creates a special_group with the given flag as child
  # of the specified parent group.
  # 
  # For example:
  #      some_page.create_special_group( :officers_parent )
  #      some_page.create_special_group( :admins_parent, :child_of => :officers_parent )
  #
  def create_special_group( group_flag, options = {} )
    raise "special group with flag :#{group_flag} already exists." if self.find_special_group( group_flag )
    
    child_of = self.find_or_create_special_group_parent_for( group_flag, options )
    new_special_group = child_of.child_groups.create
    new_special_group.add_flag( group_flag )
    return new_special_group
  end

  # If the special_group exists, return the special_group. 
  # If not, create and then return it.
  # The options argument is used for the creation.
  #
  def find_or_create_special_group( group_flag, options = {} )
    if self.find_special_group( group_flag )
      return self.find_special_group( group_flag )
    else
      return self.create_special_group( group_flag, options )
    end
  end
  
end
