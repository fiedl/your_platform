# -*- coding: utf-8 -*-
module WorkflowKit
  class AddToGroupBrick < Brick
    def name 
      "Zu Gruppe hinzufügen"
    end
    def description
      "Fügt den gegebenen Benutzer der gegebenen Gruppe als neues Mitglied hinzu. " + 
        "Die neue Gruppe muss hierbei dem Workflow-Schritt als Parameter übergeben werden."
    end
    def execute( params )
      raise 'no user_id given' unless params[ :user_id ] 
      raise 'no group_id given' unless params[ :group_id ]

      user = User.find( params[ :user_id ] )  
      group = Group.find( params[ :group_id ] )

      UserGroupMembership.create( user: user, group: group )
    end
  end
end
