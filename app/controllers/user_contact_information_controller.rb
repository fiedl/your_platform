class UserContactInformationController < ApplicationController
  
  def index
    @user = User.find params[:user_id] || raise('no user_id given')
    authorize! :read, @user
    
    set_current_navable @user
    set_current_title "#{@user.title}: #{t(:contact)}"
    set_current_activity :looks_at_contact_information, @user
    
    # FIXME: This is not true for all users:
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_user_profile
  end
    
  
end