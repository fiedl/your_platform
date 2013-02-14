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

  is_structureable( ancestor_class_names: %w(Group Page), 
                    descendant_class_names: %w(Group User Page Workflow Event) )
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

  # These methods override the standard methods, which are usual ActiveRecord associations
  # methods created by the acts-as-dag gem 
  # (https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/dag.rb).
  # But since the Workflow in the main application
  # inherits from WorkflowKit::Workflow and single table inheritance and polymorphic 
  # associations do not always work together as expected in rails, as can be seen here
  # http://stackoverflow.com/questions/9628610/why-polymorphic-association-doesnt-work-for-sti-if-type-column-of-the-polymorph,
  # we have to override these methods. 
  #
  # ActiveRecord associations require 'WorkflowKit::Workflow' to be stored in the database's
  # type column, but by asking for the `child_workflows` we want to get òbjects of the
  # `Workflow` type, not `WorkflowKit::Workflow`, since Workflow objects may have
  # additional methods, added by the main application. 
  #
  def descendant_workflows
    Workflow
      .joins( :links_as_descendant )
      .where( :dag_links => { :ancestor_type => "Group", :ancestor_id => self.id } )
      .uniq
  end

  def child_workflows
   self.descendant_workflows.where( :dag_links => { direct: true } )
  end


  # Events
  # ------------------------------------------------------------------------------------------

  def upcoming_events
    self.events.upcoming
  end


  # Users
  # ------------------------------------------------------------------------------------------

  # These methods override the standard association methods for descendant_users
  # and child_users to make sure that the `everyone` Groups do have *all* users
  # as children and descendants.
  #
  def descendant_users
    if self.has_flag?( :everyone )
      return User.all
    else
      return super 
    end
  end

  def child_users
    if self.has_flag?( :everyone )      
      return User.all
    else
      return super
    end
  end

  # This assings the given user as a member to the group, i.e. this will
  # create a UserGroupMembership.
  #
  def assign_user( user )
    if user
      unless user.in? self.child_users
        self.child_users << user if user
      end
    end
  end

  # This method will remove a UserGroupMembership, i.e. terminate the membership
  # of the given user in this group.
  #
  def unassign_user( user )
    link = DagLink.find_edge( self.becomes( Group ), user )
    if link
      link.destroy if link.destroyable?
    else
      raise "The user to unassign is not member of the group."
    end
  end


  # Groups
  # ------------------------------------------------------------------------------------------

  def descendant_groups_by_name( descendant_group_name )
    self.descendant_groups.where( :name => descendant_group_name )
  end


  # User Group Memberships
  # ------------------------------------------------------------------------------------------

  # This returns all UserGroupMembership objects of the group, including indirect 
  # memberships.
  #
  def memberships
    UserGroupMembership.find_all_by_group self 
  end

  # This returns the UserGroupMembership object that represents the membership of the 
  # given user in this group.
  # 
  def membership_of( user )
    UserGroupMembership.find_by_user_and_group( user, self )
  end

  # This returns a string of the titles of the direct members of this group. This is used
  # for in-place editing, for example.
  # 
  # The string would be something like this:
  # 
  #    "#{user1.title}, #{user2.title}, ..."
  #
  def direct_member_titles_string
    child_users.collect { |user| user.title }.join( ", " )
  end

  # This sets the memberships of a group according to the given string of user titles.
  # 
  # For example, after calling
  # 
  #    direct_member_titles_string = "#{user1.title}, #{user2.title}",
  # 
  # the users `user1` and `user2` are the only direct members of the group.
  # The memberships are removed using the standard methods, which means that the memberships
  # are only marked as deleted. See: acts_as_paranoid_dag gem.
  #
  def direct_member_titles_string=( titles_string )
    new_members_titles = titles_string.split( "," )
    new_members = new_members_titles.collect do |title|
      u = User.find_by_title( title.strip )
      self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
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

  # I'm not so sure anymore, what this was supposed to do. I guess, it had something to do
  # with inheriting group classes. 
  # TODO: Delete those methods, if there is no error after the migration to your_platform.

  #  def self.first
  #    self.all.first.becomes self
  #  end
  
  #  def self.last
  #    self.all.last.becomes self
  #  end
  
end

