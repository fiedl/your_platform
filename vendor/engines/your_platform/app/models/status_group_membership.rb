# -*- coding: utf-8 -*-
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
  has_one :status_group_membership_info, foreign_key: 'membership_id', inverse_of: :membership #, autosave: true

  delegate( :promoted_by_workflow, :promoted_by_workflow=,
            :promoted_on_event, :promoted_on_event=,
            :workflow, :workflow=, 
            :event, :event=,   # alias methods
            to: :find_or_create_status_group_membership_info )

  attr_accessible :event_by_name

  
  # Alias Methods For Delegated Methods
  # ==========================================================================================

  def create_event( params )
    find_or_create_status_group_membership_info.create_promoted_on_event( params )
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
    if event_name.present?
      if Event.find_by_name( event_name )
        self.event = Event.find_by_name( event_name )
      else
        self.create_event( name: event_name )
        self.event.group ||= self.corporation if self.corporation
        self.event.start_at = self.created_at
        self.event.save
      end
    else
      self.event = nil
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
    links = self
      .where( :descendant_type => "User" )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :valid_from )
    return links
  end

  # Returns all memberships of the given user in status groups.
  #
  def self.find_all_by_user( user )
    raise 'Expect parameter to be a User' unless user.kind_of? User
    status_groups = user.status_groups(with_invalid: true)
    status_group_ids = status_groups.collect { |group| group.id }
    links = self
      .where( :descendant_type => "User" )
      .where( :descendant_id => user.id )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :valid_from )
    return links
  end

  # Returns all memberships of the given user in the given corporation.
  #
  def self.find_all_by_user_and_corporation( user, corporation )
    self.find_all_by_user( user ).find_all_by_corporation( corporation )
  end

  # This method overrides the default finder method in order to make
  # sure the returned object is of the StatusGroupMembership type.
  #
  def self.find_by_user_and_group( user, group )
    self
      .where(ancestor_id: group.id, ancestor_type: 'Group')
      .where(descendant_id: user.id, descendant_type: 'User')
      .limit(1)
      .first
    
    # The #becomes method won't work here.
    #membership = super( user, group )
    #membership ? StatusGroupMembership.with_invalid.find(membership.id) : nil
  end


  # Save Method 
  # ==========================================================================================

  # Since several important attributes of this model are delegated, it is likely to change
  # a delegated attribute without changing a direct attribute. For example:
  #
  #    membership.workflow = some_workflow                # workflow is delegated
  #    membership.changed?                                # => false
  #    membership.status_group_membership_info.changed?   # => true
  #    membership.save
  #
  # The regular `save` method would fail, because there are `no changes` to the membership
  # itself. 
  #
  # To circumvent this, this save method first saves the delegate model if necessary and 
  # then calls the regular `save` method.
  #
  def save(*args)
    save_status_group_membership_info_if_changed
    if changed?
      return super(*args)
    else
      return true
    end
  end

  def update_attributes( attributes, options = {} )
    self.assign_attributes( attributes, options )
    save
  end

  # Callback Methods for the Delegation to status_group_membership_info
  # ==========================================================================================

  private 
  
  def find_or_create_status_group_membership_info
    status_group_membership_info || create_status_group_membership_info
  end
   
  # When .save is called on this instance, but only the associated object has changed through 
  # the delegated methods, this instance is not marked as changed. As a result, any call of 
  # .save will fail.
  #
  # This method compensates for the missing automatism.
  #
  def save_status_group_membership_info_if_changed
    find_or_create_status_group_membership_info.promoted_by_workflow.try(:save)
    find_or_create_status_group_membership_info.promoted_on_event.try(:save)
    find_or_create_status_group_membership_info.save
  end

end
