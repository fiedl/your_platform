module Api::V1
  class NavigationController < ApplicationController

    # GET /api/v1/navigation?navable=gid://wingolfsplattform/Pages::HomePage/1
    #                                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #                                          navable.to_global_id
    #
    def show
      navable || raise('no navable given')
      authorize! :read, navable

      navable.delete_cache if params[:uncached]

      respond_to do |format|
        format.json do
          render json: {
            horizontal_nav: view_context.horizontal_nav_for(navable),
            vertical_nav: view_context.vertical_nav_for(navable),
            breadcrumbs: view_context.breadcrumbs_for(navable)
          }
        end
      end
    end

    private

    def navable
      @navable ||= GlobalID::Locator.locate params[:navable].gsub("\"", "")
    end

  end
end
