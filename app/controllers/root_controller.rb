class RootController < ApplicationController
  
  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_sign_in_if_needed, :find_and_authorize_page

  def index
    set_current_navable @page
    set_current_activity :looks_at_the_start_page, @page
    set_current_access :user
    set_current_access_text :the_content_of_the_start_page_is_personalized
        
    @announcement_page = Page.find_or_create_by_flag :site_announcement
    @hide_attachment_drop_fields = true
  end
  
  
private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end
  
  # If a public website exists, which is not just a redirection, then signed-out
  # users are shown the public website.
  #
  # If no public website exists, the users are shown sign-in form.
  # 
  def redirect_to_sign_in_if_needed
    unless current_user or @need_setup
      if Page.public_website_present?
        redirect_to public_root_path
      else
        redirect_to sign_in_path
      end
    end
  end

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    authorize! :show, @page
  end
  
end
