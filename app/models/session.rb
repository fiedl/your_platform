# -*- coding: utf-8 -*-
class Session

  def initialize( session, cookies, request )
    @request = request
    @session = session
    @cookies = cookies
    
    current_user_id = read_from_session_and_cookie :current_user_id
    @current_user = User.find_by_id( current_user_id ) if current_user_id

    @layout = read_from_session_and_cookie :layout
  end

  def layout
    @layout
  end
  def layout=( new_layout )
    @layout = new_layout
    save_to_session_and_cookie :layout, @layout
  end
    

  def current_user
    @current_user
  end

  def current_user=( current_user )
    @current_user = current_user
    save_to_session_and_cookie :current_user_id, @current_user.id 
  end

  def login( user = nil )
    self.current_user = user if user
  end
    
  def logged_in?
    @current_user.kind_of? User
  end

  def logout
    destroy
  end

  def destroy
    @request.reset_session
    @current_user = nil
    @cookies.delete :current_user_id
  end

  private 

  def save_to_session_and_cookie( key, value )
    @cookies.signed[ key ] = { value: value, expires: 1.month.from_now }
    @session[ key ] = value
  end

  def read_from_session_and_cookie( key )
    value = @cookies.signed[ key ] if @cookies
    value = @session[ key ] unless value
    return value
  end


  # ==
  # Anmerkungen
  # ==

  # SF 2012-04-23
  # Ich habe auch darüber nachgedacht, den Login-Status zu speichern, also ob angemeldet oder nicht.
  # Dann könnte man die Zugangsdaten auch die Zugangsdaten in der Login-Box anzeigen beim erneuten Login.
  # Aber folgende Gründe sprechen dagegen:
  # - Der Benutzer soll die Möglichkeit erhalten, seinen Cookie sauber zu entfernen, wenn er auf "Abmelden" klickt.
  # - Man müsste zusätzliche Checkboxes wie "Benutzerdaten merken" einführen, deren Bedeutung nicht allen klar sind.


end
