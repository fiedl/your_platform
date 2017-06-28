module AutoCompletionHelper

  # options:
  #   - activator: places a pen next to the field that activates it (for boxes without edit button)
  #
  def multiple_users_best_in_place(object, attribute, options = {})
    # autocomplete_field_tag :user_title, '', autocomplete_title_users_path %>

    activator_id = options[:activator] ? "#{object.cache_key} #{attribute} multi user selector activator".parameterize : ''

    html = best_in_place( object, attribute,
                   html_attrs: {
                     'data-autocomplete-url' => titles_api_v1_users_path,
                     :class => 'multiple-users-select-input'
                   },
                   activator: (activator_id.present? ? ('#' + activator_id) : '')
                   )
    if options[:activator]
      html += (" " + best_in_place_activator(activator_id, class: 'multi_user_select_activator best_in_place_activator do_not_show_in_edit_mode')).html_safe
    end
    return html.html_safe
  end

  def user_best_in_place( object, attribute )
    best_in_place( object, attribute,
                   html_attrs: {
                     'data-autocomplete-url' => titles_api_v1_users_path,
                     :class => "user-select-input #{attribute}"
                   },
                   class: "relationships #{attribute}" )
  end

end
