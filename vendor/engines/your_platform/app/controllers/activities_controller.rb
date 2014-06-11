class ActivitiesController < ApplicationController
  def index
    authorize! :index, PublicActivity::Activity
    @activities = PublicActivity::Activity.order('created_at desc').limit(100)
  end
end
