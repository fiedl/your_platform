module AutoCompletionHelper

  # options: 
  #   - activator: places a pen next to the field that activates it (for boxes without edit button)
  #
  def multiple_users_best_in_place(object, attribute, options = {})
    # autocomplete_field_tag :user_title, '', autocomplete_title_users_path %>
    
    activator_id = options[:activator] ? "#{object.cache_key} #{attribute} multi user selector activator".parameterize : ''
    
    html = best_in_place( object, attribute, 
                   html_attrs: { 
                     'data-autocomplete-url' => autocomplete_title_users_path,
                     :class => 'multiple-users-select-input'
                   },
                   display_with: lambda { |str|
                     str.split(",").collect { |name| link_to(name.strip, search_guess_path(query: name.strip)) }.join(", ").html_safe
                   },
                   activator: (activator_id.present? ? ('#' + activator_id) : '')
                   )
    if options[:activator]
      html += link_to(content_tag(:i, '', class: 'icon-edit'), '#', id: activator_id, class: 'multi_user_select_activator', title: I18n.t(:edit)).html_safe
    end
    return html.html_safe
  end

  def user_best_in_place( object, attribute )
    best_in_place( object, attribute,
                   html_attrs: {
                     'data-autocomplete-url' => autocomplete_title_users_path,
                     :class => "user-select-input #{attribute}"
                   },
                   classes: "relationships #{attribute}" )
  end

end
