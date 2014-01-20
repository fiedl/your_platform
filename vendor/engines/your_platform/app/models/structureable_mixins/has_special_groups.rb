# -*- coding: utf-8 -*-

# This module extends the Structureable models by methods for the interaction with special_groups
# that are descendants of the structureable object.
#
# For example,
#
#     class Page
#       is_structureable ...
#       ...
#     end
#
# one would want to access the `officers_parent` group, which contains all officers of the 
# structureable object. 
#
#     some_page.find_officers_parent_group
#     some_page.create_officers_parent_group
#     some_page.find_or_create_officers_parent_group
#     some_page.officers_parent
#     some_page.officers_parent!
#     some_page.officers
#     some_page.officers << some_users
#
# Or, globally, one would use this mechanism to define, let's say, global special groups
# like the group 'everyone', which contains each and every user.
#
#     class Group
#       is_structureable ...
#       ...
#     end
#
#     Group.find_everyone_group
#     Group.create_everyone_group
#     Group.find_or_create_everyone_group
#     Group.everyone
#     Group.everyone!
#
# The `officers_parent` special group is actually defined in `StructureableMixins::Roles`,
# the `everyone` group in `GroupMixins::GlobalSpecialGroups`, whereas the helper methods that
# are used by those definitions are defined here in this mixin below.
#
module StructureableMixins::HasSpecialGroups

  extend ActiveSupport::Concern

  included do
  end

  # Global Special Groups
  # e.g. the everyone group: `Group.everyone`
  # ==========================================================================================
  #
  # These class methods may be called on each structureable model.
  # For example, one may call `Group.find_or_create_special_group(:everyone)`.
  # This is, for example, used to define the `Group.everyone` accessor.
  #
  #     class Group
  #       def self.everyone
  #         self.find_or_create_special_group(:everyone)
  #       end
  #     end
  # 
  # The `options` hash allows to specify a `parent element`, which is a structureable element
  # that is expected to be the parent element of the special group. Example:
  # 
  #     find_or_create_special_group( :corporations, parent_element: 
  #       find_or_create_special_group(:everyone) )
  #
  module ClassMethods

    def find_special_group( group_flag, options = {} )
      object_to_search = options[:parent_element].try(:child_groups) 
      object_to_search ||= Group unless options[:local]
      object_to_search.find_by_flag( group_flag.to_sym ) if object_to_search && object_to_search != [] 
    end

    def create_special_group( group_flag, options = {} )
      if find_special_group( group_flag, options )
        raise "special group :#{group_flag} already exists."
      end
      object_to_create = options[:parent_element].try(:child_groups) 
      object_to_create ||= Group unless options[:local]

      #prevent creation of :officers_parent under :officers_parent or :admins_parent
      if group_flag == :officers_parent
        unless options[:parent_element].nil?
	        if options[:parent_element].has_flag?( :officers_parent ) ||
             options[:parent_element].has_flag?( :admins_parent )
            raise "No officer group allowed under an admin or officer group!"
          end
        end
      end

      new_special_group = object_to_create.create
      new_special_group.add_flag( group_flag.to_sym )
      new_special_group.update_attribute( :name, group_flag.to_s.gsub(/_parent$/, "" ) )

      return new_special_group
    end

    def find_or_create_special_group( group_flag, options = {} )
      find_special_group(group_flag, options) or
      begin
        create_special_group(group_flag, options)
      rescue
        nil
      end
    end

  end


  # Local Special Groups
  # i.e. descendants of structureables, e.g. officers groups: `group_xy.officers_parent`
  # ==========================================================================================
  # 
  # These instance methods may be called on each structureable model instance.
  # For example, one may call `my_group.find_or_create_special_group(:officers_parent)`.
  #
  # These methods use the same mechanism as for the global special groups above
  # by specifying `self` (i.e. the structureable instance) as the `parent_element`.
  #

  def find_special_group( group_flag, options = {} )
    self.class.find_special_group( group_flag, { parent_element: self, local: true }.merge(options) )
  end

  def create_special_group( group_flag, options = {} )
    self.class.create_special_group( group_flag, { parent_element: self, local: true }.merge(options) )
  end

  def find_or_create_special_group( group_flag, options = {} )
    self.class.find_or_create_special_group( group_flag, { parent_element: self, local: true }.merge(options) ) 
  end

end

