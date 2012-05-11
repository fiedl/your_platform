module WorkflowsHelper

  def link_to_workflow( workflow, context_infos = {} )
    user = context_infos[ :user ]
    title = user.name + " " if user
    title += workflow.name_as_verb
    link_to(
            image_tag( 'tools/up.png' ) +  workflow.name,
            workflow_path( workflow, context_infos  ), 
            class: 'workflow_link',
            title: title
           )
  end

end
