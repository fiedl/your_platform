class Activities::ChartsController < ApplicationController

  def index
    authorize! :index, :activity_charts

    set_current_title t(:activity_charts)
    set_current_access :admin
    set_current_access_text :this_log_can_be_seen_by_global_admins
    set_current_breadcrumbs [
      {title: t(:activity_log), path: activities_path},
      {title: current_title}
    ]
  end


  # Charts end points: See: https://github.com/ankane/chartkick#say-goodbye-to-timeouts
  # ----------------------------------------------------------------------------------------------

  def activities_per_corporation_and_time
    authorize! :index, :activity_charts

    @activitiy_series_for_each_corporation = Corporation.all.collect { |corporation|
      {
        name: corporation.token,
        data: PublicActivity::Activity
          .where(created_at: 1.week.ago..Time.zone.now)
          .where(owner_type: 'User', owner_id: corporation.member_ids)
          .group_by_day(:created_at)
          .count
      }
    }

    render json: @activitiy_series_for_each_corporation.chart_json
  end

end