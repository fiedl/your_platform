# This handles the workflows associations of groups.
#
# These methods override the standard methods, which are usual ActiveRecord
# associations methods created by `HasDagLinks`.
# But since the `Workflow` in the main application inherits from
# `WorkflowKit::Workflow` and single table inheritance and polymorphic 
# associations do not always work together as expected in rails, 
# as can be seen here, http://stackoverflow.com/questions/9628610,
# we have to override these methods. 
#
# ActiveRecord associations require 'WorkflowKit::Workflow' to be stored 
# in the database's type column, but by asking for the `child_workflows` 
# we want to get objects of the `Workflow` type, not `WorkflowKit::Workflow`,
# since Workflow objects may have additional methods, added by the main
# application. 
#
concern :GroupWorkflows do
  
  def workflows
    child_workflows
  end
  
  def child_workflows
    Workflow
      .joins(:links_as_child)
      .where(dag_links: {ancestor_type: 'Group', ancestor_id: self.id})
      .uniq
  end
  
  def descendant_workflows
    workflows_of_self_and_connected_groups
  end
  
  def workflows_of_self_and_connected_groups
    cached do
      (workflows + connected_descendant_groups.collect(&:workflows)).flatten.uniq
    end
  end

end