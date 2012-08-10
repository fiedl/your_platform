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
             :class => 'remove_button tool show_only_in_edit_mode',
    :remote => :true
           )
  end

  def add_button( object ) # TODO: Was braucht er für minimale Informationen?
    title = t( :add )
    link_to(
            image_tag( 'tools/add.png',
                       alt: title, title: title
                       ),
            { :action => :create_profile_field, :user_id => @user.id, :type => object },
            :class => 'add_button tool show_only_in_edit_mode',
            :remote => :true
            )
  end

end
