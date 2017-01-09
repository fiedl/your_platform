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

    # The `groupdate` gem is used for date binning:
    # https://github.com/ankane/groupdate#dynamic-grouping
    group_by_period = params[:group_by_period] || params[:binning] || 'day'

    # Determine time range.
    from_days_ago = (params[:from_days_ago] || 7).to_i.days.ago
    to_days_ago = (params[:to_days_ago] || 0).to_i.days.ago

    # Filter Corporation
    if params[:corporation] == 'none'
      corporations = []
    elsif filter_corporation = params[:corporation]
      corporations = Corporation.where(token: filter_corporation)
      corporations ||= Corporation.all
    else
      corporations = Corporation.all
    end

    # Filter trackable type (Event, ...)
    trackable_type = params[:trackable_type]

    # Collect data.
    @activitiy_series_for_each_corporation = corporations.sort_by { |corporation|
      -PublicActivity::Activity
        .where(created_at: from_days_ago..to_days_ago)
        .where(trackable_type.present? ? {trackable_Type: trackable_type} : "true")
        .where(owner_type: 'User', owner_id: corporation.member_ids)
        .count
    }.collect { |corporation|
      {
        name: corporation.token,
        data: PublicActivity::Activity
          .where(created_at: from_days_ago..to_days_ago)
          .where(trackable_type.present? ? {trackable_Type: trackable_type} : "true")
          .where(owner_type: 'User', owner_id: corporation.member_ids)
          .group_by_period(group_by_period, :created_at)
          .count
      }
    }

    # Display the sum of all corporations if requested.
    if params[:sum]
      @activitiy_series_for_each_corporation += [{
        name: "Sum",
        data: PublicActivity::Activity
          .where(created_at: from_days_ago..to_days_ago)
          .where(trackable_type.present? ? {trackable_Type: trackable_type} : "true")
          .group_by_period(group_by_period, :created_at)
          .count
      }]
    end

    render json: @activitiy_series_for_each_corporation.chart_json
  end

end