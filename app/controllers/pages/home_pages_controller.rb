class Pages::HomePagesController < ApplicationController

  def index
    authorize! :index, :home_pages

    @home_pages = Page.where(type: ["Pages::HomePage"])
        .or(Page.where.not(domain: nil))
        .all
        .select { |home_page| can? :read, home_page }

    set_current_title t(:public_home_pages)
    set_current_access :admin
    set_current_access_text t :only_admins_can_access_this
  end

  def create
    authorize! :create, Pages::HomePage

    @home_page = Pages::HomePage.create title: "example.com"
    @home_page.author = current_user
    @home_page.assign_admin current_user
    @home_page.save

    redirect_to page_settings_path(@home_page)
  end

end