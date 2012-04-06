class Session

  def initialize( session_array, request )
    @request = request
    @session_array = session_array
    @current_user = User.find_by_id( @session_array[ :current_user_id ] ) if session_array[ :current_user_id ]
  end

  def current_user
    @current_user
  end

  def current_user=( current_user )
    @current_user = current_user
    @session_array[ :current_user_id ] = @current_user.id
  end

  def logged_in?
    @current_user.kind_of? User
  end

  def destroy
    @request.reset_session
    @current_user = nil
  end

end
