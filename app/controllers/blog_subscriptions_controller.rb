class BlogSubscriptionsController < ApplicationController

  expose :blog
  expose :email, -> { params[:email] }

  def create
    authorize! :subscribe_to, blog

    blog.create_subscription(email)

    redirect_to blog, notice: t(:you_have_subscribed_to_str, str: blog.title)
  end

  def destroy
    authorize! :subscribe_to, blog

    blog.unsubscribe(current_user.email) if current_user
    redirect_to blog, notice: t(:you_have_unsubscribed_str, str: blog.title)
  end

end