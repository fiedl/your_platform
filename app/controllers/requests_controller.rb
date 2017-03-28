class RequestsController < ApplicationController

  expose :requests, -> { Request.where(created_at: 1.month.ago..Time.zone.now) }
  expose :current_users, -> {
    User.find(Request.where(created_at: 5.minutes.ago..Time.zone.now).map(&:user_id).uniq)
  }
  expose :latest_requests, -> {
    Request.order('created_at desc').limit(100)
  }

  def index
    authorize! :use, :requests_index

    set_current_title "Requests"
    set_current_access :admin
    set_current_access_text :only_developers_can_access_this
  end

end