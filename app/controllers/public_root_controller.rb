 class PublicRootController < ApplicationController

  def index
    @page = public_root_page
    authorize! :read, @page

    redirect_to @page
  end

  private

  def public_root_page
    Page.find_by(title: request.host) || Page.public_root
  end

end
