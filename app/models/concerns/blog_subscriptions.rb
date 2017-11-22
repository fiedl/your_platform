concern :BlogSubscriptions do

  def subscriber_group
    BlogSubscription.find_or_create_subscribers_group_for_blog(self)
  end

  def subscribers
    subscriber_group.members
  end

  def create_subscription(email)
    BlogSubscription.create blog_id: self.id, email: email
  end

  def unsubscribe(email)
    user = User.find_by_email(email) || raise('user not found')
    subscriber_group.unassign_user user
  end

end
