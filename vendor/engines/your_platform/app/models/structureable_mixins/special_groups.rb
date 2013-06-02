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
# will give you these instance methods:
#
#     some_page.find_officers_parent_group
#     some_page.create_officers_parent_group
#     some_page.find_or_create_officers_parent_group
#     some_page.officers_parent
#     some_page.officers_parent!
#     some_page.officers # => Array of descendant_users of the officers_parent child_group
#     some_page.officers << some_users
#     some_page.officers! << some_users  # creates the officers_parent_group on the way if absent
#
# This will also work global, i.e. to produce class methods instead of instance methods.
# 
#     class Group
#       is_structureable ...
#       has_special_group :everyone, global: true
#     end
#
# This will give you these class methods:
#
#     Group.find_everyone_group
#     Group.create_everyone_group
#     Group.find_or_create_everyone_group
#     Group.everyone
#     Group.everyone!
# 
# (The user accessors are created as well if the special_group's name ends with '_parent'.)
# 
module StructureableMixins::SpecialGroups

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

#    # This method creates the accessor methods corresponding to the given group flag.
#    # See, description of StructureableMixins::HasSpecialGroup.
#    #
#    def has_special_group( group_flag, options = {} )

#      ...
#
#      if child_of
#        self.class_eval <<-EOL
#      
#        def #{self_or_not}find_or_create_#{group_flag}_group_parent
#          find_or_create_#{child_of}_group
#        end
#
#        EOL
#      else
#        self.class_eval <<-EOL
#      
#        def #{self_or_not}find_or_create_#{group_flag}_group_parent
#          self
#        end
#
#        EOL
#      end
#

  end

  # Local Special Groups
  # i.e. descendants of structureables, e.g. officers groups: `group_xy.officers_parent`
  # ==========================================================================================

  def find_special_group( group_flag, options = {} )
    self.class.find_special_group( group_flag, { parent_element: self }.merge(options) )
  end

  def create_special_group( group_flag, options = {} )
    self.class.create_special_group( group_flag, { parent_element: self }.merge(options) )
  end

  def find_or_create_special_group( group_flag, options = {} )
    self.class.find_or_create_special_group( group_flag, { parent_element: self }.merge(options) ) 
  end



  # Global Special Groups
  # i.e. independent, e.g. the everyone group: `Group.everyone`
  # ==========================================================================================

  module ClassMethods

    def find_special_group( group_flag, options = {} )
      object_to_search = options[:parent_element].try(:descendant_groups) || Group
      object_to_search.find_by_flag( group_flag.to_sym )
    end

    def create_special_group( group_flag, options = {} )
      if find_special_group( group_flag, options )
        raise "special group :#{group_flag} already exists."
      end
      object_to_create = options[:parent_element].try(:child_groups) || Group
      new_special_group = object_to_create.create
      new_special_group.add_flag( group_flag.to_sym )
      new_special_group.update_attribute( :name, ":" + group_flag.to_s.gsub("_parent", "") )
      return new_special_group
    end

    def find_or_create_special_group( group_flag, options = {} )
      find_special_group(group_flag, options) || create_special_group(group_flag, options)
    end

  end

end

