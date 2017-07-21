# -*- coding: utf-8 -*-
module WorkflowKit
  class AddToGroupBrick < Brick
    def name
      "Add User to Group"
    end
    def description
      "Add the given user to the given group as a new member. " +
        "The new group has to be passed as a parameter to the workflow step."
    end
    def execute( params )
      raise RuntimeError, 'no user_id given' unless params[ :user_id ]
      raise RuntimeError, 'no group_id given' unless params[ :group_id ]

      user = User.find( params[ :user_id ] )
      group = Group.find( params[ :group_id ] )

      membership = group.assign_user(user)

      unless membership
        # We don't want to stop the workflow here as other important steps
        # would be skipped. But notify our ticket system.
        begin
          raise RuntimeError, "Workflow brick AddToGroup for user #{params[:user_id]} and group #{params[:group_id]} has failed. No membership has been created."
        rescue => exception
          ExceptionNotifier.notify_exception(exception)
        end
      end
    end
  end
end
