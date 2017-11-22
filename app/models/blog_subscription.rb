# In the backend, blog subscriptions are handled through a "subscribers" group
# which is a subgroup of the blog. This class is just an alternate interface
# to this mechanism.
#
class BlogSubscription

  # Create a new blog subscription.
  #
  #     BlogSubscription.create blog_id: 123, email: "doe@example.com"
  #
  def self.create(params = {})
    blog = Blog.find(params[:blog_id] || raise('no blog_id given'))
    group = find_or_create_subscribers_group_for_blog(blog)
    user = find_or_create_subscriber_user(params)
    group.assign_user user
  end

  def self.find_or_create_subscribers_group_for_blog(blog)
    group = blog.child_groups.flagged(:subscribers).first
    group ||= blog.child_groups.create
    group.add_flag :subscribers
    group.name ||= I18n.t(:subscribers)
    group.save
    group
  end

  def self.find_or_create_subscriber_user(params)
    email = params[:email] || raise('no email given')
    user = User.find_by_email(email)
    user ||= User.create last_name: email, email: email
    user
  end

end