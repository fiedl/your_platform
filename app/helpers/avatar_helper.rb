module AvatarHelper

  # This returns the html code for an avatar image of the given user.
  #
  # * If the user has uploaded an avatar image using refile, this one is used.
  # * Next, the gravatar of the user's email is tried.
  # * The fallback image is defined in the `user_avatar_default_url` method.
  #
  def user_avatar(user, options = {})
    content_tag :span, "", class: 'avatar', style: "background-image: url(#{user.avatar_path})", title: user.title
  end

  # Display avatars for several users.
  #
  def user_avatars(users)
    users.collect do |user|
      link_to(user_avatar(user, size: 24), user, class: 'has_tooltip avatar_link', title: user.title, data: {placement: 'bottom'})
    end.join.html_safe
  end

end
