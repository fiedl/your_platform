# -*- coding: utf-8 -*-
module RelationshipsHelper

  def relationships_of_user_ul( user )
    relationships = user.relationships #parent_relationships + user.child_relationships
    content_tag :ul do
       (relationships.collect do |relationship|
          relationship_li relationship
       end).join.html_safe
    end
  end
  
  def relationship_li( relationship )
    who = relationship.parent_users.first
    of = relationship.child_users.first
    content_tag :li do
      [ "#{user_link who} ist #{relationship.name} von #{user_link of}".html_safe,
        relationship_tools( relationship )
      ].join.html_safe
    end
  end

  def relationship_tools( relationship )
    content_tag :span, class: 'tools only-in-edit-mode' do
      remove_button( relationship )
    end
  end

end
