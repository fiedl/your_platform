module WorkflowsHelper

  def executable_workflows_by_corporation(user)
    if @executable_workflows_by_corporation && @executable_workflows_by_corporation[user.id]
      @executable_workflows_by_corporation[user.id]
    else
      @executable_workflows_by_corporation ||= {}
      @executable_workflows_by_corporation[user.id] ||= {}
      user.workflows_by_corporation.each do |corporation_title, workflows|
        executable_workflows = workflows.select { |workflow| can? :execute, workflow }
        @executable_workflows_by_corporation[user.id][corporation_title] = executable_workflows if executable_workflows.any?
      end
      @executable_workflows_by_corporation[user.id]
    end
  end


  def link_to_workflow( workflow, context_infos = {} )
    user = context_infos[ :user ]
    title = user.name + " " if user
    title += workflow.name_as_verb
    title += " (#{workflow.corporation.name})" if workflow.corporation
    workflow_params = { user_id: user.id }
    link_to(
            (icon(workflow_icon(workflow)) + " " + workflow.name).html_safe,
            execute_status_workflow_path(workflow, workflow_params),
            method: :put,
            remote: true,
            class: "workflow_trigger #{context_infos[:class]}",
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
