corporate_vita_selector = ".corporate-vita-for-user-<%= @user.id %>"
corporate_vita = $(corporate_vita_selector)

workflow_triggers_selector = ".workflow-triggers-for-user-<%= @user.id %>"
workflow_triggers = $(workflow_triggers_selector)

new_corporate_vita = "<%= j corporate_vita_for_user(@user) %>"
new_workflow_triggers = "<%= j render partial: 'users/workflow_triggers', locals: {user: @user} %>"

corporate_vita.html(new_corporate_vita)
workflow_triggers.html(new_workflow_triggers)
