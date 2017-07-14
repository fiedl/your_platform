class PagePublicationsController < ApplicationController
  respond_to :json
  expose :page

  def create
    authorize! :publish, page

    page.update_attributes published_at: Time.zone.now

    respond_with page
  end

end