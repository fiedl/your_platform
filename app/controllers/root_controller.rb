class RootController < ApplicationController
  
  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_sign_in_if_signed_out, :find_and_authorize_page

  def index
    current_user.try(:update_last_seen_activity, "sieht sich die Startseite an", @page)
    @navable = @page
    @blog_entries = @page.blog_entries
    
    render "pages/show"
  end
  
  
private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end
  
  def redirect_to_sign_in_if_signed_out
    redirect_to sign_in_path unless current_user or @need_setup
  end

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    authorize! :show, @page
  end
  
end
