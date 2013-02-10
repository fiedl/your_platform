class StatusGroupMembershipInfo < ActiveRecord::Base

  belongs_to :membership, touch: true, class_name: "StatusGroupMembership", inverse_of: :status_group_membership_info 

  belongs_to :promoted_by_workflow, foreign_key: 'promoted_by_workflow_id', class_name: "Workflow"
  belongs_to :promoted_on_event, foreign_key: 'promoted_on_event_id', class_name: "Event"

              
  def mark_attribute_as_changed( attr_sym )
    # see: http://stackoverflow.com/questions/11460667/
    @changed_attributes[ attr_sym ] = self.send( attr_sym )
  end

end
