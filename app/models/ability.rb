# This class defines the authorization rules.
# It uses the 'cancan' gem: https://github.com/ryanb/cancan
#
# ATTENTION: This class definition below overrides the your_platform rules, which can be found at
# your_platform/app/models/ability.rb
#
class Ability
  include CanCan::Ability

  def initialize(user, params = {}, options = {})
    
    # Attention: Check outside whether the user's role allowes that preview!
    # Currently, this is done in ApplicationController#current_ability.
    #
    preview_as = options[:preview_as] 
    preview_as = nil if preview_as.blank?
    
    # Read-Only Mode
    read_only_mode = options[:read_only_mode]
    
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
      
      can :read, :terms_of_use
      can :accept, :terms_of_use

      # Only global administrators can change anything.
      #
      if user.in? Role.global_admins and not (preview_as && (preview_as != 'global_admin'))

        if read_only_mode
          can :read, :all
          can :index, :all
        else
          can :manage, :all
        end

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
        
        # Regular users can read users that are not hidden.
        # And they can read themselves.
        #
        can :read, User, id: User.find_all_non_hidden.map(&:id)
        can :read, user
        
        if not read_only_mode
          # Regular users can update their own profile.
          # They can change their first but not their surnames.
          #
          can [:update, :change_first_name, :change_alias], User, :id => user.id
          
          can :update, UserAccount, :user_id => user.id
        end
        
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
        
        if not read_only_mode
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
        end
        
        # All users can join events.
        #
        can :read, Event
        if not read_only_mode
          can :join, Event
          can :leave, Event
        end
        can :index_events, User do |other_user|
          other_user == user
        end
        
        # Name auto completion
        #
        can :autocomplete_title, User
        
        # List exports
        #   - BV-Mitgliedschaft berechtigt dazu, die Mitglieder dieses BV
        #       zu exportieren.
        #   - Mitgliedschaft in einer Verbindung als Bursch oder Philister
        #       berechtigt dazu, die Mitglieder dieser Verbindung zu
        #       exportieren.
        #   - Normale Gruppen-Mitgliedschaften (etwa Gruppe 'Jeder' 
        #       oder 'Wingolfsblätter-Abonnenten') berechtigen nicht zum
        #       Export.
        #
        can :export_member_list, Group do |group|
          if group.bv?
            user.in? group.members
          elsif group.corporation
            user.in?(group.corporation.philisterschaft.members) or 
            user.in?(group.corporation.descendant_groups.where(name: 'Burschen').first.members)
          else
            false
          end
        end
        
        # LOCAL ADMINS
        # Local admins can manage their groups, this groups' subgroups 
        # and all users within their groups. They can also execute workflows.
        #
        if user.admin_of_anything? and not (preview_as && (preview_as != 'admin')) and not read_only_mode
          can :manage, Group do |group|
            group.admins_of_self_and_ancestors.include? user
          end
          cannot :rename, Group do |group|
            group.flags.present?
          end
          cannot :update_memberships, Group do |group|
            # only global admins are allowed to manage local admins.
            #
            group.has_flag? :admins_parent
          end
          cannot :create_officers_group_for, Group
          cannot :destroy, Group do |group|
            group.descendant_users.count > 0
          end
          can :manage, User, id: Role.of(user).administrated_users.map(&:id)
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
        if preview_as.blank? or preview_as.in? ['officer', 'admin']
          can :export_member_list, Group do |group|
            user.in? group.officers_of_self_and_ancestor_groups
          end

          if not read_only_mode
            
            # Group emails
            #
            can :create_post_for, Group do |group|
              user.in?(group.officers_of_self_and_ancestor_groups) || user.in?(group.corporation.try(:officers) || [])
            end

            # Local officers can create events in their groups.
            #
            can :create_event, Group do |group|
              user.in? group.officers_of_self_and_ancestor_groups
            end
            can :update, Event do |event|
              event.group && user.in?(event.group.officers_of_self_and_ancestor_groups)
            end
            can :update, Group do |group|
              group.has_flag?(:contact_people) && can?(:update, group.parent_events.first)
            end
            
            # Create, update and destroy Pages
            #
            can :create_page_for, [Group, Page] do |parent|
              parent.officers_of_self_and_ancestors.include?(user)
            end
            can :update, Page do |page|
              (page.author == user) && (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
            end
            can :destroy, Page do |page|
              can? :update, page
            end
            
            # Create, update and destroy Attachments
            #
            can :create_attachment_for, Page do |page|
              (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
            end
            can :update, Attachment do |attachment|
              (attachment.parent.group) && (attachment.parent.group.officers_of_self_and_ancestors.include?(user)) &&
              ((attachment.author == user) || (attachment.parent.author == user))
            end
            can :destroy, Attachment do |attachment|
              can? :update, attachment
            end
          end
        end
        
        # GLOBAL_OFFICERS
        # Bundesämter sind im Moment mit dem Flag :global_officer versehen.
        # Bundesamtsträger dürfen insbesondere:
        #
        #   - Beliebige Mitglieder-Listen exportieren
        #   - Nachrichten an beliebige Gruppen schicken
        #
        if preview_as.blank? or preview_as.in? ['officer', 'admin', 'global_officer']
          if Role.of(user).global_officer?
            can :export_member_list, Group
            if not read_only_mode
              can :create_post_for, Group
            end
          end
        end
        
        # DEVELOPERS
        can :use, Rack::MiniProfiler do
          user.developer?
        end
        
      end
      
    end  # not logged in:
    
    # Imprint
    # Make sure all users (even if not logged in) can read the imprint.
    #
    can :read, Page do |page|
      page.has_flag? :imprint
    end
    
    # Listing Events and iCalendar (ICS) Export:
    #
    # There are event lists on public websites and webcal feeds.
    # Therefore the user might not be logged in through a regular
    # session. Some public feeds can be seen by anyone. Other
    # feeds require an auth token.
    # 
    can :index_events, Group do |group|
      # Any registered user (identified by an auth token)
      # can index the events of any group.
      params[:token].present? && UserAccount.find_by_auth_token(params[:token])
    end
    can :index_events, User do |other_user|
      # To index the events relevant to a certain user,
      # one has to provide the correct auth token that corresponds
      # to that user.
      params[:token].present? && (UserAccount.find_by_auth_token(params[:token]) == other_user.account)
    end
    can :index_public_events, :all
    
  end
end
