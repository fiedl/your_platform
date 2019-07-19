module LastEmail

  def last_email
    15.times do
      return ActionMailer::Base.deliveries.last if ActionMailer::Base.deliveries.last.present?
      sleep 0.3
    end
    return nil
  end

  def email_text
    last_email.to_s
  end

end