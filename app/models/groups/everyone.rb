# That special group has all users as members.
#
class Groups::Everyone < Group
  after_create { add_flag(:everyone) }

  def members
    User.all
  end

  def direct_members
    User.all
  end

  def self.find_or_create
    self.first || self.create
  end
end