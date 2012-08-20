# -*- coding: utf-8 -*-
module ToolButtonsHelper
  
  def remove_button( object )
    title = t( :remove )
    title += ": " + object.title if object.respond_to? :title
    link_to( content_tag( :i, "", :class => "icon-trash icon-white" ),
         #    image_tag( 'tools/remove.png', 
         #               alt: title, title: title
         #               ).html_safe,
             object,
             method: 'delete',
             :class => 'remove_button tool show_only_in_edit_mode btn btn-danger',
             :title => title
           )
  end

  def add_button( url ) # TODO: Was braucht er für minimale Informationen?
    title = t( :add )
    link_to( content_tag( :i, "", :class => "icon-plus icon-white" ) +
             title,
        #    image_tag( 'tools/add.png',
        #               alt: title, title: title
        #               ).html_safe,
            url.to_s,
            :class => 'add_button tool show_only_in_edit_mode btn btn-success'
            )
  end

end
