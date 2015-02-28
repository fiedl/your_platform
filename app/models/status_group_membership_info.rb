class StatusGroupMembershipInfo < ActiveRecord::Base
  
  attr_accessible

  belongs_to :membership, touch: true, class_name: "StatusGroupMembership", inverse_of: :status_group_membership_info 

  belongs_to :promoted_by_workflow, foreign_key: 'promoted_by_workflow_id', class_name: "Workflow"
  belongs_to :promoted_on_event, foreign_key: 'promoted_on_event_id', class_name: "Event"


  # Alias Methods
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


end
