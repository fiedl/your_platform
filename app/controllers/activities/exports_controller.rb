class Activities::ExportsController < ApplicationController

  def index
    authorize! :read, :exports_log
    @activities = PublicActivity::Activity.where('`key` like ?', "Export%").limit(1000)

    set_current_title t(:exports_log)
    set_current_access :admin
    set_current_access_text :this_log_can_be_seen_by_global_admins
    set_current_breadcrumbs [
      {title: t(:activity_log), path: activities_path},
      {title: current_title}
    ]

    render 'activities/index'
  end

end