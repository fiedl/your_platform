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
      [ user_best_in_place( relationship, :who_by_title ),
        content_tag( :span, " " + t( :is ) + " ", :class => "junction_expression" ),
        best_in_place( relationship, :is ),
        content_tag( :span, " " + t( :of ) + " ", :class => "junction_expression" ),
        user_best_in_place( relationship, :of_by_title ),
        # "#{user_link who} ist #{relationship.name} von #{user_link of}".html_safe, # TODO: User-Links
        relationship_tools( relationship )
      ].join.html_safe
    end
  end

  def relationship_tools( relationship )
    content_tag :span, class: 'tools only-in-edit-mode' do
      remove_button( relationship )
    end
  end

# def user_best_in_place_if_not_me( object, user_attribute, me_user )
#   if object.send( user_attribute ) == me_user
#     me_user.title
#   else
#     best_in_place( object, user_attribute )
#   end
# end

end
