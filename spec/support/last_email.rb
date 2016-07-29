module LastEmail

  def last_email
    5.times do
      return ActionMailer::Base.deliveries.last if ActionMailer::Base.deliveries.last.present?
      sleep 1
    end
    return nil
  end

  def email_text
    last_email.to_s
  end

end