module UsersHelper

  def user_link( user )
    link_to( user.name, controller: 'users', action: 'show', alias: user.alias )
  end

  def editable_first_and_last_name( user )
    (best_in_place_if(can?(:change_first_name, user), user, :first_name) + " " +
      best_in_place_if(can?(:change_last_name, user), user, :last_name)
    ).html_safe
  end

  def link_to_user_with_phone_number(user)
    if user.phone.present?
      link_to(user.title, user, class: 'user') + ", " + I18n.t(:fon) + ": " + content_tag(:span, user.phone, class: 'phone')
    else
      link_to(user.title, user, class: 'user')
    end
  end

  def link_to_user_with_avatar(user, path = nil)
    link_to(user_avatar(user) + " " + content_tag(:span, user.title, class: 'user_title'), path || user_path(user))
  end

end
