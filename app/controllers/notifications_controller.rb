class NotificationsController < ApplicationController

  load_and_authorize_resource except: [:read_all]
  skip_authorization_check only: [:read_all]
  
  def show
    @notification.update_attribute :read_at, Time.zone.now
    redirect_to @notification.reference_url
  end
  
  # PATCH notifications/read_all
  #
  # This marks all notifications of the current_user as read.
  #
  def read_all
    current_user.notifications.upcoming.update_all read_at: Time.zone.now
    redirect_to :back, change: 'notifications_menu'
  end
  
end