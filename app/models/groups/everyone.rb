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

  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end
end