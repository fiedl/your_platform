class BlogSubscriptionConfirmationsController < ApplicationController

  expose :token, -> { params[:token] }
  expose :subscription_info, -> {
    Rails.cache.read(["blog_subscriptions", token]) || raise('this token is invalid or has expired.')
  }
  expose :user, -> { User.find subscription_info[:user_id] }
  expose :blog, -> { Blog.find subscription_info[:blog_id] }

  def create
    authorize! :subscribe_to, blog

    blog.create_subscription(user.email)

    redirect_to blog, notice: t(:you_have_subscribed_to_str, str: blog.title)
  end

end