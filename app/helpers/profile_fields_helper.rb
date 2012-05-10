module ProfileFieldsHelper

  def profile_field_span_tag( profile_field, options = { action: "show"} )
    action = options[ :action]
    editable_span_tag( css_class: "profile_field #{action}", 
                       object: profile_field, 
                       controller: "profile_fields", 
                       id: profile_field.id 
                       ) do
      profile_field_span_tag_inner_html profile_field, options
    end
  end

  def profile_field_span_tag_inner_html( profile_field, options )
    return pf_show_action_inner_html( profile_field, options ) if options[ :action ] == "show"
    return pf_edit_action_inner_html( profile_field, options ) if options[ :action ] == "edit"
  end

  private

  def pf_show_action_inner_html( profile_field, options )
    value = profile_field.value
    if value
      value = value.gsub( /\n/, '<br />' )
      if profile_field.type == "Address"
        value = value.gsub( ', ', '<br />' )
        value += "<br />(" + link_to( profile_field.bv.name, profile_field.bv.becomes( Group ) ) + ")"
      end
    end

    [ content_tag( :dt, profile_field.label ),
      content_tag( :dd ) do
        if value
          value.html_safe
        elsif profile_field.children.count > 0
          content_tag :dl do
            profile_field.children.collect do |child_field|
              content_tag :span do
                profile_field_span_tag_inner_html child_field, options
              end
            end.join.html_safe
          end
        end
      end
    ].join.html_safe
  end

  def pf_edit_action_inner_html( profile_field, options )
    form_for :profile_field, url: { action: 'update' } do |form|
      [ form.hidden_field( :id ),
        content_tag( :dt ) do
          [ form.text_field( :label, class: 'text label' ),
            link_to( image_tag( 'tools/remove.png', alt: t( :remove ), title: t( :remove ) ).html_safe,
                     url_for( action: 'destroy', id: profile_field.id ),
                     class: 'remove_button' )
          ].join.html_safe
        end,
        content_tag( :dd ) do
          if profile_field.type == "Address" or profile_field.type == "Description"
            form.text_area :value, class: "text multiline #{profile_field.type}"
          else
            form.text_field :value, class: "text #{profile_field.type}"
          end
        end
      ].join.html_safe
    end
  end
  

end
