class LogosController < ApplicationController

  expose :page, -> { Page.find params[:page_id] if params[:page_id] }
  expose :scope, -> { page }

  expose :logos, -> {
    if scope
      Attachment.where(parent_type: 'Page', parent_id: [scope.id] + scope.child_pages.pluck(:id)).logos
    else
      Attachment.logos
    end
  }

  def index
    authorize! :manage, :logos

    if scope
      set_current_title t(:logo_settings_for_str, str: scope.domain || scope.title)
    else
      set_current_title :logo_settings
    end
  end

end