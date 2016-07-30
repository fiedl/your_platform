class IncomingMails::PostMail < IncomingMail

  def process(options = {})
    return [self]
  end

end