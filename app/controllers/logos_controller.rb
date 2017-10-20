class LogosController < ApplicationController

  expose :page, -> { Page.find params[:page_id] if params[:page_id] }
  expose :scope, -> { page }

  expose :logos, -> {
    if scope
      Attachment.where(parent_type: 'Page', parent_id: scope.child_pages.pluck(:id)).logos
    else
      Attachment.logos
    end
  }

  def index
    authorize! :manage, :logos
  end

end