# This ability class defines the basic structure for our role-based
# authorization system.
# 
# You can either override it completely or use the following method
# to defined your own rights.
#
#     # app/model/ability.rb
#     require_dependency YourPlatform::Engine.root.join('app/models/ability').to_s
#     
#     module AbilityDefinitions
#       def rights_for_local_admins
#         super
#         can :do, :amazing_things
#       end
#     end
# 
#     class Ability
#       prepend AbilityDefinitions
#     end
#
# For an extensive example, have a look at:
# https://github.com/fiedl/wingolfsplattform/blob/master/app/models/ability.rb
# 
class Ability
  include CanCan::Ability

  def initialize(user, params = {}, options = {})
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

    # Attention: Check outside whether the user's role allowes that preview!
    # Currently, this is done in ApplicationController#current_ability.
    #
    @preview_as = options[:preview_as] 
    @preview_as = nil if @preview_as.blank?
    @role = options[:role].try(:to_s)
  
    @read_only_mode = options[:read_only_mode]
    @params = params
    @user = user
        
    if user
      if user.global_admin? and view_as?(:global_admin)
        rights_for_global_admins
      end
      if user.admin_of_anything? and view_as?(:admin)
        rights_for_local_admins
      end
      if view_as?([:officer, :admin])
        rights_for_local_officers
      end
      if Role.of(user).global_officer? and view_as?([:global_officer, :officer, :admin])
        rights_for_global_officers
      end
      if user.developer?
        rights_for_developers
      end
      rights_for_signed_in_users
    end
    rights_for_everyone

  end
  
  def view_as?(role)
    (view_as.nil?) or (view_as.to_s == '') or if role.kind_of?(Array)
      view_as.in? role
    else
      view_as == role
    end
  end
  def view_as
    preview_as.try(:to_sym)
  end
  def preview_as
    @preview_as
  end
  def read_only_mode?
    @read_only_mode
  end
  def params
    @params
  end
  def user
    @user
  end
  def role
    @role.try(:to_s)
  end
  
  def rights_for_developers
    can :use, Rack::MiniProfiler
  end
  
  def rights_for_global_admins
    if read_only_mode?
      can :read, :all
      can :index, :all
    else
      can :manage, :all
    end
  end
  
  def rights_for_local_admins
    if not read_only_mode?
      can :manage, Group do |group|
        group.admins_of_self_and_ancestors.include? user
      end
    end
  end
  
  def rights_for_local_officers
    can :export_member_list, Group do |group|
      user.in? group.officers_of_self_and_ancestors
    end
    
    if not read_only_mode?
      # Group emails
      #
      can [:create_post, :create_post_for], Group do |group|
        user.in?(group.officers_of_self_and_ancestor_groups) || user.in?(group.corporation.try(:officers) || [])
      end
    
      # Local officers can create events in their groups.
      #
      can [:create_event, :create_event_for], Group do |group|
        user.in? group.officers_of_self_and_ancestor_groups
      end
      can [:update, :destroy], Event do |event|
        event.group && user.in?(event.group.officers_of_self_and_ancestor_groups)
      end
      can :update, Group do |group|
        group.has_flag?(:contact_people) && can?(:update, group.parent_events.first)
      end
      
      # Local officers of pages can edit their pages and sub-pages
      # as long as they are the authors or the pages have *no* author.
      #
      can :update, Page do |page|
        can?(:read, page) and page.officers_of_self_and_ancestors.include?(user) and (page.author == user or page.author.nil?)
      end
      
      # Local officers of pages can add attachments to the page and subpages
      # and modify their own attachments.
      #
      can :create_attachment_for, Page do |page|
        can?(:read, page) and page.officers_of_self_and_ancestors.include?(user)
      end
      can [:update, :destroy], Attachment do |attachment|
        can?(:read, attachment.parent) and 
        can?(:read, attachment) and 
        attachment.author == user
      end
      
      # Local officers can also modify any attachment of their own pages 
      # in order to review their own pages.
      #
      can [:update, :destroy], Attachment do |attachment|
        can?(:read, attachment.parent) and 
        can?(:read, attachment) and 
        (attachment.parent.respond_to?(:author) && attachment.parent.author == user)
      end
    end
  end
  
  def rights_for_global_officers
    can :export_member_list, Group
    if not read_only_mode?
      can [:create_post, :create_post_for], Group
      can [:create_event, :create_event_for], Group
      can [:update, :destroy], Event do |event|
        event.contact_people.include? user
      end
    end
  end
      
  def rights_for_signed_in_users
    can :read, :terms_of_use
    can :accept, :terms_of_use if not read_only_mode?
    
    # Regular users can read users that are not hidden.
    # And they can read themselves.
    #
    can :read, User, id: User.find_all_non_hidden.pluck(:id)
    can :read, user
        
    if not read_only_mode?
      # Regular users can create, update or destroy own profile fields
      # that do not belong to the General section.
      #
      can [:create, :read, :update, :destroy], ProfileField do |field|
        field.profileable.nil? or # to allow creating fields
        ((field.profileable == user) and (field.type != 'ProfileFieldTypes::General'))
      end
      
      # Regular users can update their own validity ranges of memberships
      # in order to update their corporate vita.
      #
      can :update, UserGroupMembership, :descendant_id => user.id
    end
    
    can :read, Group do |group|
      # Regular users cannot see the former_members_parent groups
      # and their descendant groups.
      #
      not (group.has_flag?(:former_members_parent) || group.ancestor_groups.find_all_by_flag(:former_members_parent).count > 0)
    end
    
    can :read, Page do |page|
      page.group.nil? || page.group.members.include?(user)
    end
    can [:read, :download], Attachment do |attachment|
      attachment.parent.try(:group).nil? || attachment.parent.try(:group).try(:members).try(:include?, user)
    end
        
    # All users can join events.
    #
    can :read, Event
    if not read_only_mode?
      can :join, Event
      can :leave, Event
    end
    can :index, Event
    can :index_events, Group
    can :index_events, User, :id => user.id
    can :upload_image, Event do |event|
      event.attendees.include?(user) or event.contact_people.include?(user)
    end
    
    # If a user is contact person of an event, he can provide pages and
    # attachment for this event.
    # 
    can [:update, :create_page_for], Event do |event|
      event.contact_people.include? user
    end
    can [:update, :create_attachment_for], Page do |page|
      page.ancestor_events.map(&:contact_people).flatten.include? user
    end
    
    # Name auto completion
    #
    can :autocomplete_title, User
  end
  
  def rights_for_everyone
    # Imprint
    # Make sure all users (even if not logged in) can read the imprint.
    #
    can :read, Page, Page.flagged(:imprint) do |page|
      page.has_flag?(:imprint)
    end
    
    # Listing Events and iCalendar (ICS) Export:
    #
    # There are event lists on public websites and webcal feeds.
    # Therefore the user might not be logged in through a regular
    # session. Some public feeds can be seen by anyone. Other
    # feeds require an auth token.
    # 
    if params[:token].present?
      tokened_user = UserAccount.find_by_auth_token(params[:token])
      if tokened_user
        can :index_events, Group
        can :index_events, User do |other_user|
          # To index the events relevant to a certain user,
          # one has to provide the correct auth token that corresponds
          # to that user.
          tokened_user == other_user.account
        end
      end
    end
    can :index_public_events, :all
    
    # Nobody can destroy events that are older than 10 minutes.
    timestamp = 10.minutes.ago
    cannot :destroy, Event, ["created_at >= ?", timestamp] do |event|
      event.created_at < timestamp
    end
    
  end
end
