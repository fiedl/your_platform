# This helper provides a method to include in the layout file in order to show
# an area presenting the flash messages sent by a controller.
# Note: Flash does refer to alert messages, not the vector graphics tool by adobe.
#
# http://guides.rubyonrails.org/action_controller_overview.html#the-flash
#
module FlashHelper
  
  def flash_area
    flash.collect do |type, message|
      alert_field(type, message)
    end.join("\n").html_safe
  end
  
  # Show a twitter bootstrap alert field.
  # Possible types (bootstrap): info (blue), success (green), warning (yellow), danger (red)
  # Possible types (rails):     notice (-> info), alert (-> warning)
  # Possible types (custom):    error (-> danger)
  #
  # http://getbootstrap.com/components/#alerts
  #
  def alert_field(type, message)
    type = bootstrap_alert_type(type)
    # message = make_first_part_of_the_message_bold(message)
    content_tag :div, :class => "alert alert-#{type}" do
      close_button + message
    end.html_safe
  end
  
  private
  
  # Converts the given type to a type string used by twitter bootstrap.
  # http://getbootstrap.com/components/#alerts
  #
  def bootstrap_alert_type(type)
    type = type.to_s
    # type = "success" if ...
    type = "info" if type == "notice"
    type = "warning" if type == "alert"
    type = "danger" if type == "error"
    return type
  end
  
  def close_button
    content_tag :button, "×", {:class => "close", :data => {:dismiss => :alert}, :type => "button"}
  end
  
end
