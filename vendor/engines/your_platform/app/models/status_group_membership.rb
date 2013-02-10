# 
# This class represents the membership of a user in a status group, i.e. a subgroup of a corporation
# representing a member status, e.g. the subgroup 'guests' or 'presidents'.
#
class StatusGroupMembership < UserGroupMembership

  # Status Group Memberships do have more properties than regular memberships;
  # those new properties are, e.g., shown in the corporate_vita.
  # Since rails apparently does not support Multi Table Inheritance,
  # this associated model takes the additional properties.
  # 
  has_one :status_group_membership_info, foreign_key: 'membership_id', inverse_of: :membership, autosave: true

  delegate( :promoted_by_workflow, :promoted_by_workflow=,
            :promoted_on_event, :promoted_on_event=,
            to: :status_group_membership_info )

  after_initialize :build_status_group_membership_info_if_nil
  before_validation :save_status_group_membership_info_if_changed
  before_create :mark_as_changed

  
  # Alias Methods For Delegated Methods
  # ==========================================================================================

  # Promoted By Workflow
  # ------------------------------------------------------------------------------------------
  #
  # Status Group Memberships can store the workflow that has promoted the user to this
  # status. This is used, for example, in the corporate vita, since the title of the
  # promotion workflow is to be shown there, rather than the title of the new status group.
  # 
  # Example:
  #     membership.promoted_by_workflow = workflow   # long form
  #     membership.workflow = workflow               # short form
  #     membership.promoted_by_workflow.title        # long form
  #     membership.workflow.title                    # short form
  #
  def workflow
    self.promoted_by_workflow
  end
  def workflow=( workflow )
    self.promoted_by_workflow = workflow
  end

  # Promoted On Event
  # ------------------------------------------------------------------------------------------
  # 
  # This stores the event on which the promotion took place that caused the user to be
  # in this status group.
  #
  # Example:
  #     membership.promoted_on_event = event         # long form
  #     membership.event = event                     # short form
  #     membership.promoted_on_event.name            # long form
  #     membership.event.title                       # short form
  # 
  def event
    self.promoted_on_event
  end
  def event=( event )
    self.promoted_on_event = event
  end

  # Access the event (promoted_on_event) by its name, since this is the way
  # most likely done by a user interface.
  # 
  # If a new event is created, assign the corporation associated with this status group
  # as the group of the event.
  #
  def event_by_name
    self.event.name if self.event
  end
  def event_by_name=( event_name )
    if Event.find_by_name( event_name )
      self.event = Event.find_by_name( event_name )
    else
      self.event = Event.new( name: event_name )
      self.event.group ||= self.corporation if self.corporation

      #status_group_membership_info.mark_attribute_as_changed( :promoted_on_event )
      # @changed_attributes[ :event ] = self.event
      self.updated_at = DateTime.now
      status_group_membership_info.updated_at = DateTime.now
    end
  end


  # Creator
  # ==========================================================================================

  def self.create( params )
    super( params ).becomes StatusGroupMembership 
  end
    

  # Finder Methods
  # ==========================================================================================

  # Returns all memberships in status groups that belong to the given corporation.
  # 
  # corporation A
  #      |------------- status group 1
  #      |                      |-------- user 1
  #      |                      |-------- user 2
  #      |------------- status group 2
  #                             |-------- user 3
  # 
  # The method therefore will return all memberships of subgroups of the corporation.
  # 
  def self.find_all_by_corporation( corporation )
    raise 'Expect parameter to be a Corporation' unless corporation.kind_of? Corporation
    status_groups = corporation.status_groups
    status_group_ids = status_groups.collect { |group| group.id }
    links = StatusGroupMembership
      .where( :descendant_type => "User" )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :created_at )
    return links
  end

  # Returns all memberships of the given user in status groups.
  #
  def self.find_all_by_user( user )
    raise 'Expect parameter to be a User' unless user.kind_of? User
    status_groups = user.status_groups
    status_group_ids = status_groups.collect { |group| group.id }
    links = StatusGroupMembership
      .where( :descendant_type => "User" )
      .where( :descendant_id => user.id )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :created_at )
    return links
  end

  # Returns all memberships of the given user in the given corporation.
  #
  def self.find_all_by_user_and_corporation( user, corporation )
    self.find_all_by_user( user ).find_all_by_corporation( corporation )
  end

  def self.find_by_user_and_group( user, group )
    # The #becomes method won't work here.
    StatusGroupMembership.find( super( user, group ).id ) 
  end



  # Callback Methods for the Delegation to status_group_membership_info
  # ==========================================================================================

  private 

  # Since methods of this associated object are delegated to this class, the associated object
  # is required to exist. Thus, if it is nil, build one!
  #
  def build_status_group_membership_info_if_nil
    build_status_group_membership_info unless status_group_membership_info
  end
  
  # When .save is called on this instance, but only the associated object has changed through 
  # the delegated methods, this instance is not marked as changed. As a result, any call of 
  # .save will fail.
  #
  # To fix this issue, the associated object is saved manually, here, if changed.
  # After that, the updated_at of this instance is touched in order to mark this instance
  # as changed. Otherwise, the save call will be cancelled and the transaction will be
  # reverted. 
  #
  def save_status_group_membership_info_if_changed
    if status_group_membership_info.changed?
      status_group_membership_info.save 
      mark_as_changed
    end
  end

  # Just mark this instance as changed to avoid the 'no changes' error on save.
  # See: http://apidock.com/rails/ActiveRecord/Dirty
  #
  def mark_as_changed
    self.updated_at = DateTime.now
  end

end
