class PublicRootController < ApplicationController

  def index
    @page = Page.public_root
    authorize! :read, @page

    redirect_to @page
  end

end
