module AvatarHelper

  # This returns the html code for an avatar image of the given user.
  # At the moment, this image is just provided by gravatar.
  #
  def user_avatar( user, options = {} )

    email = user.email
    options[:size] ||= 36
    options[:gravatar] ||= {}
    options[:gravatar][:size] ||= options[:size]
    #options[:alt] ||= "Gravatar: #{email}"
    #options[:title] ||= options[:alt]
    options['data-toggle'] ||= 'tooltip'
    options[:gravatar][:secure] = true
    
    options[:class] ||= ""
    options[:class] += " img-rounded"

    # Default Url
    # Instead of 
    #     URI.join(root_url, asset_path('avatar_128.png'))
    # we use a string at the moment, in order to make this work
    # locally as well. Otherwise a 'http://localhost/...' would be 
    # submitted to gravatar as source of the default image.
    # 
    options[:gravatar][:default] ||= user_avatar_default_url 
    
    render partial: 'shared/avatar', formats: [:html], locals: { email: email, options: options }

  end
  
  def user_avatar_url( user, options = {} )
    options[:gravatar] ||= {}
    options[:gravatar][:default] ||= user_avatar_default_url
    options[:gravatar][:size] ||= 36
    options[:gravatar][:secure] = true
    gravatar_image_url(user.email, options)
  end
  
  def user_avatar_default_url
    "https://wingolfsplattform.org/assets/avatar_128.png"
  end
  
end
