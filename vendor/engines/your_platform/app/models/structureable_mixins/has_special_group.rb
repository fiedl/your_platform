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
#
# This will also work global, i.e. to produce class methods instead of instance methods.
# 
#     class Group
#       is_structureable ...
#       has_special_group :everyone, global: true
#     Group
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
module StructureableMixins::HasSpecialGroup

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # This method creates the accessor methods corresponding to the given group flag.
    # See, description of StructureableMixins::HasSpecialGroup.
    #
    def has_special_group( group_flag, options = {} )
      child_of = options[ :child_of ]
      global = options[ :global ]

      # if the special_group is global, the accessors have to be 
      # class methods, not instance methods.
      self_or_not = "self." if global 

      # TODO: Maybe use a block instead: 
      # http://stackoverflow.com/questions/1011142/include-a-module-to-define-dynamic-class-method
      self.class_eval <<-EOL  

      def #{self_or_not}#{group_flag}
        find_#{group_flag}_group
      end

      def #{self_or_not}#{group_flag}!
        find_or_create_#{group_flag}_group
      end

      def #{self_or_not}find_#{group_flag}_group
        find_special_group( '#{group_flag}' )
      end

      def #{self_or_not}create_#{group_flag}_group
        create_special_group( '#{group_flag}', { child_of: '#{child_of}' } )
      end

      def #{self_or_not}find_or_create_#{group_flag}_group
        g = find_#{group_flag}_group
        g ||= create_#{group_flag}_group
      end

      EOL

      if child_of
        self.class_eval <<-EOL
      
        def #{self_or_not}find_or_create_#{group_flag}_group_parent
          find_or_create_#{child_of}_group
        end

        EOL
      else
        self.class_eval <<-EOL
      
        def #{self_or_not}find_or_create_#{group_flag}_group_parent
          self
        end

        EOL
      end

      if group_flag.to_s.end_with?( '_parent' ) # e.g. "admins_parent"
        reduced_group_flag = group_flag.to_s.gsub( /_parent$/, "" ) # e.g. "admins"

        # Warning! If the method already exists (even it is defined after `has_special_group` outside,
        # it is going to be overridden here. Therefore, we only replace it if it does not exist.
        # http://stackoverflow.com/questions/5944278/overriding-method-by-another-defined-in-module
        #
        if not self.respond_to? reduced_group_flag
          self.class_eval <<-EOL

          def #{self_or_not}#{reduced_group_flag}
            return #{group_flag}.descendant_users if #{group_flag}
          end

          EOL
        end
      end

    end
  end

  # This method finds the group of all descendant_groups of this object that matches
  # the given flag.
  #
  def find_special_group( group_flag )
    self.descendant_groups.find_by_flag( group_flag.to_sym )
  end
  module ClassMethods
    def find_special_group( group_flag )
      Group.find_by_flag( group_flag.to_sym )
    end
  end

  # This method creates a special_group with the given flag as child
  # of the specified parent group.
  #
  # For example:
  #      some_page.create_special_group( :officers_parent )
  #      some_page.create_special_group( :admins_parent, :child_of => :officers_parent )
  #      Page.create_special_group( :global_admins_parent ) # global special_group
  #
  def create_special_group( group_flag, options = {} )

    if self.find_special_group( group_flag )
      raise "special group with flag '#{group_flag}' already exists."
    end
    
    child_of = self.send( "find_or_create_#{group_flag}_group_parent" )

    new_special_group = child_of.child_groups.create
    new_special_group.add_flag( group_flag.to_sym )
    return new_special_group
  end
  module ClassMethods
    def create_special_group( group_flag, options = {} )
      
      if self.find_special_group( group_flag )
        raise "global special group with flag '#{group_flag}' already exists."
      end
    
      child_of = self.send( "find_or_create_#{group_flag}_group_parent" )

      if child_of.kind_of? Class
        new_special_group = Group.create
      else
        new_special_group = child_of.child_groups.create
      end

      new_special_group.add_flag( group_flag.to_sym )
      return new_special_group
      
    end
      
  end
end

