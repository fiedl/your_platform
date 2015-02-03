module UsersHelper

  def user_link( user )
    link_to( user.name, controller: 'users', action: 'show', alias: user.alias )
  end
  
  def editable_first_and_last_name( user )
    (best_in_place_if(can?(:change_first_name, user), user, :first_name) + " " +
      best_in_place_if(can?(:change_last_name, user), user, :last_name)
    ).html_safe
  end

end
