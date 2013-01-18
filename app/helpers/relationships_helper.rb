# -*- coding: utf-8 -*-
module RelationshipsHelper

  def relationships_of_user_ul( user )
    relationships = user.relationships #parent_relationships + user.child_relationships
    content_tag( :ul ) do
      [ relationship_lis( relationships ),
        relationship_tools_common_li( user: user )
      ].join.html_safe
     end
  end

  def relationship_lis( relationships )
    ( relationships.collect do |relationship|
      relationship_li( relationship )
    end ).join.html_safe
  end
  
  def relationship_li( relationship )
    who = relationship.who
    of = relationship.of
    content_tag :li do
      [ user_best_in_place( relationship, :who_by_title ),
        content_tag( :span, " " + t( :is ) + " ", :class => "junction_expression" ),
        best_in_place( relationship, :is ),
        content_tag( :span, " " + t( :of ) + " ", :class => "junction_expression" ),
        user_best_in_place( relationship, :of_by_title ),
        # "#{user_link who} ist #{relationship.name} von #{user_link of}".html_safe, # TODO: User-Links
        relationship_tools_each( relationship )
      ].join.html_safe
    end
  end

  def relationship_tools_each( relationship )
    show_only_in_edit_mode_span do
      remove_button( relationship )
    end
  end

  def relationship_tools_common_li( options = {} )
    show_only_in_edit_mode_span do
      content_tag :li do
        relationship_tools_common( options )
      end
    end
  end

  def relationship_tools_common( options = {} )
    user = options[ :user ]
    data = {}
    data = { :user_id => user.id, :user_title => user.title, :relationship_is_label => "Leibbursch" } if user
    add_button( relationships_path, :method => :post, :data => data )
  end

# def user_best_in_place_if_not_me( object, user_attribute, me_user )
#   if object.send( user_attribute ) == me_user
#     me_user.title
#   else
#     best_in_place( object, user_attribute )
#   end
# end

end
