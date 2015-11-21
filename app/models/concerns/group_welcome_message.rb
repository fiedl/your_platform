concern :GroupWelcomeMessage do
  
  included do
    delegate :welcome_message, :welcome_message=, to: :settings
    attr_accessible :welcome_message
  end
  
  def send_welcome_message_to(user)
    
  end
  
end