# This class defines the authorization rules.
# It uses the 'cancan' gem: https://github.com/ryanb/cancan
#
# ATTENTION: This class definition below overrides the your_platform rules, which can be found at
# your_platform/app/models/ability.rb
#
class Ability
  include CanCan::Ability

  def initialize(user, options = {})
    preview_as_user = true if options[:preview_as_user]
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    alias_action :create, :read, :update, :destroy, :to => :crud

    # This behaviour is temporary!
    #
    # Only registered users can do or see anything.
    #
    if user

      # Only global administrators can change anything.
      #
      if user.in? Role.global_admins and not preview_as_user
        can :manage, :all

      else
        
        # ATTENTION: Do not use `can :read, :all` anymore.
        # Anything that can be read has to be specified explicitely.
        
        # REGULAR USERS
        can :read, Page do |page|
          page.group.nil? || page.group.members.include?(user)
        end
        can :download, Attachment do |attachment|
          attachment.parent.try(:group).nil? || attachment.parent.try(:group).try(:members).try(:include?, user)
        end

        can :read, Group  # exceptions below:
        
        # Regular users cannot see the former_members_parent groups
        # and their descendant groups.
        #
        cannot :read, Group do |group|
          group.has_flag?(:former_members_parent) || group.ancestor_groups.find_all_by_flag(:former_members_parent).count > 0
        end
        
        can :read, User  # exceptions below:

        # Regular users cannot see hidden users, except for self.
        #
        cannot :read, User do |user_to_show|
          user_to_show.hidden? && (user != user_to_show)
        end
        
        # Regular users can update their own profile.
        #
        can :update, User, :id => user.id
        can :update, UserAccount, :user_id => user.id
        
        # Regular users can read profile fields of profiles they are allowed to see.
        # Exceptions below.
        #
        can :read, ProfileField do |profile_field|
          can? :read, profile_field.profileable
        end
        
        # Regular users can only see their own bank accounts
        # as well as bank accounts of non-user objects, i.e. groups.
        #
        cannot :read, ProfileField do |field|
          parent_field = field
          while parent_field.parent != nil do
            parent_field = parent_field.parent
          end

          (parent_field.type == 'ProfileFieldTypes::BankAccount') &&
            parent_field.profileable.kind_of?(User) && (parent_field.profileable.id != user.id)
        end
        
        # Regular users can create, update or destroy own profile fields.
        #
        can :crud, ProfileField do |field|
          (field.profileable == user) || field.profileable.nil?
        end

        # Regular users can update their own validity ranges of memberships
        # in order to update their corporate vita.
        #
        can :update, UserGroupMembership do |user_group_membership|
          user_group_membership.user == user
        end
        
        # All users can join events.
        #
        can :read, Event
        can :join, Event        
        
        # LOCAL ADMINS
        # Local admins can manage their groups, this groups' subgroups 
        # and all users within their groups. They can also execute workflows.
        #
        if user.admin_of_anything? and not preview_as_user
          can :manage, Group do |group|
            group.admins_of_self_and_ancestors.include? user
          end
          can :manage, User do |other_user|
            other_user.admins_of_ancestor_groups.include? user
          end
          can :execute, Workflow do |workflow|
            # Local admins can execute workflows of groups they're admins of.
            # And they can execute the mark_as_deceased workflow, which is a global workflow.
            # if they do administrate a group.
            #
            (workflow == Workflow.find_mark_as_deceased_workflow) ||
              workflow.admins_of_ancestors.include?(user)
          end
          can :manage, Page do |page|
            page.admins_of_self_and_ancestors.include? user
          end
          can :manage, ProfileField do |profile_field|
            profile_field.profileable.nil? ||  # in order to create profile fields
              can?(:manage, profile_field.profileable)
          end
          can :manage, UserGroupMembership do |membership|
            can? :manage, membership.user
          end
        end
        
        # LOCAL OFFICERS
        # Local officers can export the member lists of their groups.
        #
        can :export_member_list, Group do |group|
          user.in? group.officers_of_self_and_parent_groups
        end
        
        # Local officers can create events in their groups.
        #
        can :create_event, Group do |group|
          user.in? group.officers_of_self_and_parent_groups
        end
        can :update, Event do |event|
          user.in? event.group.officers_of_self_and_parent_groups
        end
        
        # DEVELOPERS
        can :use, Rack::MiniProfiler do
          user.developer?
        end
        
      end
      
    else  # not logged in

      # Imprint
      # Make sure all users (even if not logged in) can read the imprint.
      #
      can :read, Page do |page|
        page.has_flag? :imprint
      end
      
      # iCalendar (ICS) Export
      # All users can export calendars without login, since 
      # feeding to calendar applications should work.
      #
      # TODO: Check personal token
      #
      can :ics_export, Group
      
    end
  end
end
