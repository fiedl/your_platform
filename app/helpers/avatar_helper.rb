module AvatarHelper

  def user_avatar(user, options = {})
    avatar user, options
  end

  def group_avatar(group, options = {})
    options[:icon] = "fa fa-group"
    avatar group, options
  end

  def avatar(object, options = {})
    content_tag :span, class: "avatar #{options[:class]}", style: "background-image: url(#{object.avatar_path})", title: object.title do
      content_tag :i, "", class: options[:icon] unless object.avatar_path
    end
  end

  # Display avatars for several users.
  #
  def user_avatars(users)
    users.collect do |user|
      link_to(user_avatar(user, size: 24), user, class: 'has_tooltip avatar_link', title: user.title, data: {placement: 'bottom'})
    end.join.html_safe
  end

end
