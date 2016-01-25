module WorkflowsHelper

  def link_to_workflow( workflow, context_infos = {} )
    user = context_infos[ :user ]
    title = user.name + " " if user
    title += workflow.name_as_verb
    title += " (#{workflow.wah_group.name})" if workflow.wah_group
    workflow_params = { user_id: user.id }
    link_to(
            (icon(workflow_icon(workflow)) + " " + workflow.name).html_safe,
            execute_workflow_path( workflow, workflow_params ), 
            method: :put,
            :class => 'workflow_trigger',
            title: title
            )
  end
  
  def workflow_icon(workflow)
    if workflow.steps.collect { |step| step.brick_name }.include? 'DestroyAccountAndEndMembershipsIfNeededBrick'
      "remove"
    else
      "chevron-up"
    end
  end
  
  def workflow_execution_links_for( options )

    group = options[ :group ]
    user = options[ :user ]

    group.child_workflows.collect do |workflow|
      link_to_workflow workflow, user: user
    end.join.html_safe    

  end

end
