class WebsitesController < ApplicationController

  expose :group
  expose :home_page, -> { group.public_home_page }

  def show
    raise "Für #{group.name} wurde noch keine öffentliche Website mit der Plattform erstellt." unless home_page
    authorize! :read, home_page

    redirect_to home_page
  end

  def create
    authorize! :update, group

    new_home_page = group.generate_public_website
    redirect_to new_home_page
  end

  expose :groups_with_websites, -> { Group.where(id: Group.joins(:child_pages).merge(Page.public_pages)) }
  expose :active_corporations, -> { Group.where(id: Corporation.active) }
  expose :groups, -> { groups_with_websites.or active_corporations }

  def index
    authorize! :index, Pages::HomePage

    set_current_tab :contacts
    set_current_title "Öffentliche Internetauftritte"
  end

end