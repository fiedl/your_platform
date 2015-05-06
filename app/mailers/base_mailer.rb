class BaseMailer < ActionMailer::Base
  helper MailerHelper
  default from: 'wingolfsplattform@wingolf.org'
  
  # This method overrides the original delivery method in order to
  # handle cases where the message cannot be delivered. In those
  # cases, the email adress is marked as 'invalid'.
  #
  def deliver
    begin
      super
    rescue Net::SMTPFatalError, Net::SMTPSyntaxError => error
      logger.debug error
      logger.warn error.message
      recipient_address_needs_review!
      return false
    end
  end
  
  def recipient_address_needs_review!
    raise 'no recipient address' unless headers[:to].present?
    logger.warn "Adding :needs_review flag to email address #{headers[:to]}."
    ProfileFieldTypes::Email.where(value: headers[:to]).needs_review!
  end

end