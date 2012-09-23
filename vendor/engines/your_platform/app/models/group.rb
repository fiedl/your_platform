# -*- coding: utf-8 -*-
#
# This class represents a user group. Besides users, groups may have sub-groups as children.
# One group may have several parent-groups. Therefore, the relations between groups, users,
# etc. is stored using the DAG model, which is implemented by the `is_structureable` method.
# 
class Group < ActiveRecord::Base
  attr_accessible( :name, # just the name of the group; example: 'Corporation A'
                   :token, # (optional) a short-name, abbreviation of the group's name, in 
                           # a global context; example: 'A'
                   :internal_token, # (optional) an internal abbreviation, i.e. used by the 
                                    # members of the group; example: 'AC'
                   :extensive_name, # (optional) a long version of the group's name;
                                    # example: 'The Corporation of A'
                   :direct_member_titles_string # Used for inline-editing: The comma-separated
                                                # titles of the child users of the group.
                   )

  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group User Page Workflow)
  is_navable
  has_profile_fields

  include GroupMixins::SpecialGroups
  include GroupMixins::Import

  after_create     :import_default_group_structure  # from GroupMixins::Import

  
  # General Properties
  # ==========================================================================================

  # The title of the group, i.e. a kind of caption, e.g. used in the <title> tag of the
  # webpage. By default, this returns just the name of the group. But this may be changed
  # in the main application.
  # 
  def title
    self.name
  end


  # Associated Objects
  # ==========================================================================================

  # Workflows
  # ------------------------------------------------------------------------------------------

  def descendant_workflows
    Workflow
      .joins( :links_as_descendant )
      .where( :dag_links => { :ancestor_type => "Group", :ancestor_id => self.id } )
      .uniq
  end

  def child_workflows
   self.descendant_workflows.where( :dag_links => { direct: true } )
  end


  # Users
  # ------------------------------------------------------------------------------------------

  def descendant_users
    if self == Group.jeder
      return User.all
    else
      return super 
    end
  end

  def child_users
    if self == Group.jeder
      return descendant_users
    else
      return super
    end
  end

  def assign_user( user )
    if user
      unless user.in? self.child_users
        self.child_users << user if user
      end
    end
  end

  def unassign_user( user )
    link = DagLink.find_edge( self.becomes( Group ), user )
    link.destroy if link.destroyable? if link
  end



  # Groups
  # ------------------------------------------------------------------------------------------

  def descendant_groups_by_name( descendant_group_name )
    self.descendant_groups.where( :name => descendant_group_name )
  end


  # User Group Memberships
  # ------------------------------------------------------------------------------------------

  def memberships
    UserGroupMembership.find_all_by_group self 
  end

  def membership_of( user )
    UserGroupMembership.find_by_user_and_group( user, self )
  end

  def direct_member_titles_string
    child_users.collect { |user| user.title }.join( ", " )
  end

  def direct_member_titles_string=( titles_string )
    new_members_titles = titles_string.split( "," )
    new_members = new_members_titles.collect do |title|
      u = User.find_by_title( title.strip )
      self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
#      raise 'validation error: user not found: #{title}'
      u
    end
    for member in child_users
      unassign_user member unless member.in? new_members if member
    end
    for new_member in new_members
      assign_user new_member if new_member
    end
  end



  # Finder Methods
  # ==========================================================================================

  def self.first
    self.all.first.becomes self
  end

  def self.last
    self.all.last.becomes self
  end



end

