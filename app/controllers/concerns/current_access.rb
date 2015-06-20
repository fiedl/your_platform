concern :CurrentAccess do
  
  included do
    helper_method :current_access, :current_access_text, :current_access_icon
    helper_method :append_to_current_access_text
  end
  
  # This sets the current access indicator.
  #
  # access_levels are:
  #   access_level   |  explanation                  |  icon
  # - public         |  all internet users           |  globe
  # - admin          |  admin access                 |  user-secret
  # - signed_in      |  all signed-in users          |  users
  # - group          |  only group members           |  unlock
  # - user           |  personalized content         |  user
  # - none           |  no access (admins override)  |  lock
  #
  def set_current_access(access_level)
    @current_access = access_level
  end
  def current_access
    @current_access
  end
  
  def current_access_icon
    case current_access.to_s
    when 'public'; 'globe'
    when 'signed_in'; 'users'
    when 'group'; 'unlock'
    when 'admin'; 'user-secret'
    when 'user'; 'user'
    when 'none'; 'lock'
    end
  end
  
  # For the access indicator, this provides a useful help text.
  #
  def set_current_access_text(text)
    @current_access_text = text
  end
  def current_access_text
    I18n.translate(@current_access_text, default: @current_access_text)
  end
  def append_to_current_access_text(text)
    @current_access_text = I18n.t(@current_access_text, default: @current_access_text)
    @current_access_text += "\n#{I18n.t(text, default: text)}"
  end
end