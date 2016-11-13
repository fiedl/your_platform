class GuestUser < User

  def self.find_or_create(name, email)
    if email.present? && guest = GuestUser.find_by_email(email)
      guest
    elsif email.present? && User.find_by_email(email)
      nil # no guest!
    elsif name.present? && guest = GuestUser.find_by_name(name)
      guest
    else
      GuestUser.create(name: name, email: email)
    end
  end

  def self.find_by_email(email)
    user = super(email)
    if user.try(:account)
      nil  # It's no guest if there is an account.
    else
      user
    end
  end

  def self.find_by_name(name)
    self.find_all_by_name(name).without_email.without_account.last
  end

  def self.create(args)
    user = self.new
    if args[:email].present? and not args[:name].present?
      args[:name] = args[:email].split("@").first
    elsif args[:name].present? and not args[:email].present?
      args[:email] = nil
    end
    user.name = args[:name]
    user.email = args[:email]
    user.save
    return user
  end

end