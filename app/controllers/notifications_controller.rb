class NotificationsController < ApplicationController
  load_and_authorize_resource
  
  def show
    @notification.update_attribute :read_at, Time.zone.now
    redirect_to @notification.reference_url
  end
end