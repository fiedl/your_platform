# -*- coding: utf-8 -*-
module WorkflowKit
  class RemoveFromGroupBrick < Brick
    def name 
      "Remove User from Group"
    end
    def description
      "Quit the membership of the user that is passed to this workflow as parameter " + 
        "in the group that is passed to the workflow as parameter."
    end
    def execute( params )
      raise 'no user_id given' unless params[ :user_id ]
      raise 'no group_id given' unless params[ :group_id ]

      user = User.find( params[ :user_id ] ) 
      group = Group.find( params[ :group_id ] )

      membership = UserGroupMembership.find_by( user: user, group: group )
      if membership  # probably the user was not in the group
        if membership.direct? # probably the group is a group without direct members
          membership.invalidate
        else
          membership.direct_memberships.each { |m| m.invalidate } 
        end
      end
    end
  end
end
