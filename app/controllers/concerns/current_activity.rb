concern :CurrentActivity do
  
  def set_current_activity(text, object = nil)
    message = translate(text, default: text)
    message += ": #{object.title}" if object and object.respond_to?(:title)
    current_user.try(:update_last_seen_activity, message, object)
  end
  
  def destroy_current_activity
    current_user.update_last_seen_activity(nil) if current_user
  end
  
end