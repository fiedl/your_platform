class HorizontalNav
  def initialize(args)
    @user = args[:user]
    @navable = args[:current_navable]
  end
  
  def self.for_user(user, args = {})
    self.new(args.merge({ user: user }))
  end
  
  def navables
    @user.try(:parent_groups)
  end
end
