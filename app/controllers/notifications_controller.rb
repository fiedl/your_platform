class NotificationsController < ApplicationController

  load_and_authorize_resource except: [:read_all, :index]
  skip_authorization_check only: [:read_all]
  
  def index
    @notifications = current_user.notifications.order('created_at desc')
    authorize! :index, Notification
    
    set_current_navable Page.intranet_root
    set_current_title t(:notifications)
    set_current_activity :looks_at_notifications
  end
  
  def show
    @notification.update_attribute :read_at, Time.zone.now
    redirect_to @notification.reference_url
  end
  
  # PATCH notifications/read_all
  #
  # This marks all notifications of the current_user as read.
  #
  def read_all
    current_user.notifications.unread.update_all read_at: Time.zone.now
    redirect_to :back, change: 'notifications_menu'
  end
  
end