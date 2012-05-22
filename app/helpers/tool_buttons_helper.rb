# -*- coding: utf-8 -*-
module ToolButtonsHelper
  
  def remove_button( object )
    title = t( :remove )
    title += ": " + object.title if object.respond_to? :title
    link_to( image_tag( 'tools/remove.png', 
                        alt: title, title: title 
                        ).html_safe,
             object,
             method: 'delete',
             :class => 'remove_button'
           )
  end

  def add_button( object ) # TODO: Was braucht er für minimale Informationen?
    title = t( :add )
    link_to(
            image_tag( 'tools/add.png',
                       alt: title, title: title
                       ).html_safe,
            { :action => :new },
            :class => 'add_button'
            )
  end

end
