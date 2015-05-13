class SupportRequestsController < ApplicationController
  skip_authorization_check only: :create
  
  def create
    authorize! :create, :support_request
    
    @sender_user = current_user
    @to_email = SupportRequestsController.support_email
    @navable = GlobalID::Locator.locate(params[:navable]) if params[:navable].present?
    @text = params[:text]
    @meta_data = {
      sent_over: 'Help-Button',
      browser: params[:browser],
      os: params[:os],
      viewport: params[:viewport],
      locale: I18n.locale,
      location: params[:location],
      displayed_navable_object: @navable.inspect,
      role: Role.of(current_user).for(@navable).to_s
    }
    
    SupportRequestMailer.support_request_email(@sender_user, @to_email, @text, @meta_data, @navable).deliver_now
    
    head :no_content
  end
  
  def self.support_email
    if Setting.support_email
      Setting.support_email
    else
      logger.warn('No support email address (support@example.com) set. Please set it using the Setting.support_email accessor.')
      return "support@example.com"
    end
  end
  
end