class RootController < ApplicationController

  before_filter :redirect_to_sign_in_if_signed_out, :find_and_authorize_page

  def index
    current_user.try(:update_last_seen_activity, "sieht sich die Startseite an", @page)
    @navable = @page
    @blog_entries = @page.blog_entries
    render "pages/show"
  end

  private

  def redirect_to_sign_in_if_signed_out
    redirect_to sign_in_path unless current_user
  end

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    reload_ability
    authorize! :show, @page
  end
end
