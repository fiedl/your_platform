module WorkflowsHelper

  def link_to_workflow( workflow, context_infos = {} )
    user = context_infos[ :user ]
    title = user.name + " " if user
    title += workflow.name_as_verb
    link_to(
            image_tag( 'tools/up.png' ) +  workflow.name,
            workflow_kit.execute_workflow_path( workflow, context_infos ), 
            method: :put,
            :class => 'workflow_link',
            title: title
            )
  end
  
  def workflow_execution_links_for( options )
    #( workflow: workflow, group: child_group, user: user )
    group = options[ :group ]
    user = options[ :user ]

    group.child_workflows.collect do |workflow|
      link_to_workflow workflow, user: user
    end.join.html_safe    

  end

end
