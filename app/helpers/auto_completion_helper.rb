module AutoCompletionHelper

  def multiple_users_best_in_place( object, attribute )
    # autocomplete_field_tag :user_title, '', autocomplete_title_users_path %>
    best_in_place( object, attribute, 
                   html_attrs: { 
                     'data-autocomplete-url' => autocomplete_title_users_path,
                     :class => 'multiple-users-select-input'
                   },
                   display_with: lambda { |str|
                     str.split(",").collect { |name| link_to(name.strip, search_guess_path(query: name.strip)) }.join(", ").html_safe
                   } )
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
