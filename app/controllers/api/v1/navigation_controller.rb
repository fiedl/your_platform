module Api::V1
  class NavigationController < ApplicationController

    # GET /api/v1/navigation?navable=gid://wingolfsplattform/Pages::HomePage/1
    #                                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #                                          navable.to_global_id
    #
    def show
      navable || raise('no navable given')
      authorize! :read, navable

      horizontal_nav = Rails.cache.renew_if(params[:uncached]) do
        view_context.horizontal_nav_for(navable, home_page: navable.home_page)
      end

      respond_to do |format|
        format.json do
          render json: {
            horizontal_nav: render_partial('layouts/horizontal_nav', object: horizontal_nav, as: :horizontal_nav)
            #vertical_nav: view_context.vertical_nav_for(navable),
            #breadcrumbs: view_context.breadcrumbs_for(navable)
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
