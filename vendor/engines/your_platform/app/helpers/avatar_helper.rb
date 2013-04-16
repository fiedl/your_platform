module AvatarHelper

  # This returns the html code for an avatar image of the given user.
  # At the moment, this image is just provided by gravatar.
  #
  def user_avatar( user, options = {} )

    email = user.email
    options[:size] ||= 36
    options[:gravatar] ||= {}
    options[:gravatar][:size] ||= options[:size]
    options[:alt] ||= "Gravatar: #{email}"
    options[:title] ||= options[:alt]
    options['data-toggle'] ||= 'tooltip'
    options[:gravatar][:default] ||= URI.join(root_url, asset_path('avatar_128.png'))

    render partial: 'shared/avatar', locals: { email: email, options: options }

  end

end
