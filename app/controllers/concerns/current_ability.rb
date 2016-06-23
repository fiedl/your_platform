concern :CurrentAbility do

  included do
  end

  # This overrides the `current_ability` method of `cancan`
  # in order to allow additional options that are needed for a preview mechanism.
  #
  # Warning! Make sure to handle these options very carefully to not allow
  # malicious injections.
  #
  # The original method can be found here:
  # https://github.com/ryanb/cancan/blob/master/lib/cancan/controller_additions.rb#L356
  #
  def current_ability(reload = false, options = {})
    if reload
      @current_ability = nil
      @current_role = nil
      @current_role_view = nil
    end

    if @current_ability.nil?
      # Auth token. This can either be a permanent `User#token`,
      # e.g. for calender feeds, or it can be an `AuthToken#token`,
      # which allows access to a certain resource.
      #
      options[:token] = current_auth_token
      options[:user_by_auth_token] = current_user_by_auth_token

      # Read-only mode
      options[:read_only_mode] = true if read_only_mode?

      # Preview role mechanism
      options[:preview_as] = current_role_preview
    end

    @current_ability ||= ::Ability.new(current_devise_user, options)
  end
  def reload_ability
    current_ability(true)
  end

  def current_ability_as_user(reload = false, options = {})
    #if reload
    #  @current_ability = nil
    #  @current_role = nil
    #  @current_role_view = nil
    #end

    if @current_ability_as_user.nil?
      options[:read_only_mode] = true if read_only_mode?
      options[:preview_as] = 'user'
    end

    @current_ability_as_user ||= ::Ability.new(current_user, options)
  end

  def unauthorized!
    #   The unauthorized! method has been removed from CanCan, use authorize! instead.
    authorize! :read_what_is, :unauthorized
  end

end