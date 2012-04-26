module UsersHelper

  def user_link( user )
    link_to( user.name, controller: 'users', action: 'show', alias: user.alias )
  end

end
