class PagePublicationsController < ApplicationController

  expose :page

  def create
    authorize! :publish, page

    page.update_attributes published_at: Time.zone.now

    redirect_to :back
  end

end