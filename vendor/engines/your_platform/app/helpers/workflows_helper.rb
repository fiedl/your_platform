module WorkflowsHelper

  def link_to_workflow( workflow, context_infos = {} )
    user = context_infos[ :user ]
    title = user.name + " " if user
    title += workflow.name_as_verb
    title += " (#{workflow.wah_group.name})" if workflow.wah_group
    workflow_params = { user_id: user.id }
    link_to(
            (tag(:i, :class => "icon-chevron-up") + " " + workflow.name).html_safe,
            workflow_kit.execute_workflow_path( workflow, workflow_params ), 
            method: :put,
            :class => 'workflow_trigger',
            title: title
            )
  end
  
  def workflow_execution_links_for( options )

    group = options[ :group ]
    user = options[ :user ]

    group.child_workflows.collect do |workflow|
      link_to_workflow workflow, user: user
    end.join.html_safe    

  end

end
