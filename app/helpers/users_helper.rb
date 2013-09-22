module UsersHelper

  def user_link( user )
    link_to( user.name, controller: 'users', action: 'show', alias: user.alias )
  end
  
  def editable_first_and_last_name( user )
    if can? :update, user
      "#{best_in_place(user, :first_name)} #{best_in_place(user, :last_name)}"
    else
      user.name
    end.html_safe
  end

end
